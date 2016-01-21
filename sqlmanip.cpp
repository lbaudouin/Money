#include "sqlmanip.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>

#include <QColor>

#ifdef USE_DB_CONFIG
#include "connection_params.h"
#else
#define DB_HOST "localhost"
#define DB_BASE "base"
#define DB_USER "user"
#define DB_PASSWORD "password"
#endif

SqlManip::SqlManip(QObject *parent) :
    QObject(parent)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
    db.setHostName(DB_HOST);
    db.setDatabaseName(DB_BASE);
    db.setUserName(DB_USER);
    db.setPassword(DB_PASSWORD);
    if(!db.open()){
        qDebug() << "Failed to open";
    }
}

QJsonValue SqlManip::getShops()
{
    QSqlQuery query("SELECT id, name, image FROM shops");
    qDebug() << query.lastQuery();

    QJsonArray a;

    while (query.next()) {
        QJsonObject o;
        o.insert("code", query.value(0).toInt());
        o.insert("name", query.value(1).toString());
        o.insert("image",query.value(2).toString());

        a.append( o );
    }

    QJsonObject o;
    o.insert("code", 0);
    o.insert("name", tr("Add") );
    o.insert("image",QString("add.png") );

    a.append( o );

    return QJsonValue(a);
}

int SqlManip::createReceipt(int shop, QDate date)
{
    QSqlQuery query( QString("INSERT INTO receipts(shop,date) VALUES(%1,'%2')").arg(shop).arg(date.toString(Qt::ISODate)) );
    qDebug() << query.lastQuery();

    if(query.lastError().type()!=QSqlError::NoError){
        qDebug() << query.lastError().text();
        return -1;
    }
    return query.lastInsertId().toInt();
}

QJsonValue SqlManip::getReceipt(int receiptID)
{
    QSqlQuery query(QString("SELECT name, price, promo "
                    "FROM articles, article_receipt "
                    "WHERE article_receipt.receiptID=%1 AND articles.id=article_receipt.articleID").arg(receiptID));
    qDebug() << query.lastQuery();

    QJsonArray a;

    while (query.next()) {
        QJsonObject o;
        o.insert("name", query.value(0).toString());
        o.insert("price", query.value(1).toDouble());
        o.insert("promo", query.value(2).toDouble());

        a.append( o );
    }

    return a;
}

QJsonValue SqlManip::getReceipts()
{
    QSqlQuery query("SELECT date, shops.name, (SELECT sum(price-promo) FROM article_receipt WHERE article_receipt.receiptID=receipts.id) as total FROM receipts, shops WHERE receipts.shop=shops.id ORDER BY date ASC");
    qDebug() << query.lastQuery();
    QJsonArray a;

    while (query.next()) {
        QJsonObject o;

        o.insert("date", query.value(0).toDate().toString());
        o.insert("shop", query.value(1).toString());
        o.insert("total",query.value(2).toDouble());

        a.append( o );
    }

    return QJsonValue(a);
}

QJsonValue SqlManip::getArticles(int shop)
{
    QSqlQuery query(QString("SELECT articles.id, articles.name "
                            "FROM articles, article_receipt, receipts "
                            "WHERE receipts.shop=%1 AND article_receipt.receiptID=receipts.id AND article_receipt.articleID=articles.id").arg(shop));
    qDebug() << query.lastQuery();

    QJsonArray a;

    while (query.next()) {
        QJsonObject o;

        o.insert("code", query.value(0).toInt());
        o.insert("name", query.value(1).toString());
        o.insert("image", "");

        a.append( o );
    }

    return QJsonValue(a);
}

QString SqlManip::getShopName(int shopID)
{
    QSqlQuery query(QString("SELECT name FROM shops WHERE id=%1").arg(shopID));
    qDebug() << query.lastQuery();
    query.first();
    return query.value(0).toString();
}

void SqlManip::removeReceipt(int receiptID)
{
    QSqlQuery query;
    query.exec(QString("DELETE FROM receipts WHERE id=%1").arg(receiptID));
    qDebug() << query.lastQuery();
    query.exec(QString("DELETE FROM article_receipt WHERE receiptID=%1").arg(receiptID));
    qDebug() << query.lastQuery();
}

void SqlManip::addArticleToReceipt(int receiptID, QString articleName, int quantity, double price, double promo)
{
    int articleID = -1;
    QSqlQuery query;
    //WARNING: protect against sql injection !!!
    query.exec( QString("SELECT id FROM articles WHERE name='%1'").arg(articleName));
    qDebug() << query.lastQuery();

    if(query.size()>0){
        query.first();
        articleID = query.value(0).toInt();
    }else{

        query.exec( QString("INSERT INTO articles(name) VALUES('%1')").arg(articleName));
        qDebug() << query.lastQuery();
        articleID = query.lastInsertId().toInt();
    }

    for(int i=0;i<quantity;i++){
        query.exec( QString("INSERT INTO article_receipt( articleID, receiptID, price, promo) VALUES (%1,%2,%3,%4)")
                    .arg(articleID).arg(receiptID).arg(price).arg(promo));
        qDebug() << query.lastQuery();
    }
}

QString SqlManip::findArticle(QString prefix)
{
    QSqlQuery query("SELECT name FROM articles");

    QString smallest;

    QStringList list;
    while (query.next()) {
        QString str = query.value(0).toString();
        if(str.startsWith(prefix,Qt::CaseInsensitive)){
            if(smallest.isEmpty() || (str.size() < smallest.size()))
                smallest = str;
            list << str;
        }
    }

    if(list.isEmpty())
        return QString();

    if(list.size()==1){
        return list.first();
    }

    QString common = smallest.left(prefix.size());
    for(int i=prefix.size();i<smallest.size();i++){
        QString c = common + smallest.at(i);
        bool isCommon = true;
        for(int j=0;j<list.size();j++){
            if(!list.at(j).startsWith(c,Qt::CaseInsensitive)){
                isCommon = false;
                break;
            }
        }
        if(!isCommon)
            break;
        common = c;
    }

    qDebug() << common << list;

    return common;
}

QJsonValue SqlManip::getCategoryStats(int categoryID)
{
    QSqlQuery query("SELECT id, name, parent, (SELECT sum(price-promo) FROM articles, article_receipt WHERE articles.categoryID=categories.id AND articles.id=article_receipt.articleID) as total FROM categories");

    qDebug() << query.lastQuery();
    if(query.lastError().type()!=QSqlError::NoError){
        qDebug() << query.lastError().text();
    }

    QList<CatData> catDatas;

    QMap<int,int> parents;
    QMap<int,QString> names;

    names[-1] = "All";

    while (query.next()) {
        CatData d;
        d.id = query.value(0).toInt();
        d.name = query.value(1).toString();
        d.parent = query.value(2).toInt();
        d.total = query.value(3).toDouble();

        parents[d.id] = d.parent;
        names[d.id] = d.name;

        catDatas << d;
    }

    QList<QColor> colors;
    colors << QColor("#CC0000");
    colors << QColor("#CC6600");
    colors << QColor("#CCCC00");
    colors << QColor("#66CC00");
    colors << QColor("#00CCCC");
    colors << QColor("#0066CC");
    colors << QColor("#000066");
    colors << QColor("#6600CC");
    colors << QColor("#CC00CC");


    QJsonObject obj;
    obj.insert("id", categoryID);
    obj.insert("name", names[categoryID]);
    obj.insert("parent", parents[categoryID]);

    QJsonArray a;

    int k = 0;

    for(int i=0;i<catDatas.size();i++){
        if(catDatas.at(i).parent==categoryID){

            QJsonObject o;

            o.insert("id", catDatas.at(i).id);
            o.insert("name", catDatas.at(i).name);
            o.insert("value", catDatas.at(i).total + sum(catDatas,catDatas.at(i).id));
            o.insert("color", colors.at( k++ % colors.size()).name() );

            a.append( o );
        }
    }

    obj.insert("sub",a);

    return QJsonValue(obj);
}

double SqlManip::sum(QList<CatData> &list, int parent) const
{
    double total = 0.0;
    for(int i=0;i<list.size();i++){
        if(list.at(i).parent==parent){
            total += list.at(i).total + sum(list,list.at(i).id);
        }
    }
    return total;
}
