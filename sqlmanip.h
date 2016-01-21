#ifndef SQLMANIP_H
#define SQLMANIP_H

#include <QObject>
#include <QJsonValue>
#include <QDate>

struct CatData{
    int id;
    QString name;
    int parent;
    double total;
};

class SqlManip : public QObject
{
    Q_OBJECT
public:
    explicit SqlManip(QObject *parent = 0);

protected:
    double sum(QList<CatData> &list, int parent) const;

signals:

public slots:
    QJsonValue getArticles(int shop);
    QJsonValue getReceipts();
    QJsonValue getReceipt(int receiptID);

    QJsonValue getShops();
    QString getShopName(int shopID);

    int createReceipt(int shop, QDate date);
    void removeReceipt(int receiptID);

    void addArticleToReceipt(int receiptID, QString articleName, int quantity, double price, double promo);

    QString findArticle(QString prefix);

    QJsonValue getCategoryStats(int categoryID);

};

#endif // SQLMANIP_H
