import QtQuick 2.0

import "qchart/"
import "qchart/QChart.js" as Charts

Rectangle {
    id: graph

    /*Categories:
    -0: Inconnu
    -1: Alimentaire:
        -10: Autres
        -11: Boissons
            -110: Autres
            -111: Laits
            -112: Eau
            -113: Jus
            -114: Alcool
            -115: Thés & tisanes
        -12: Fruits & Légumes
            -120: Autres
            -121: Fruits
            -122: Légumes
            -123: Légumes secs
        -13: Produits frais
            -130: Autres
            -131: Crèmerie
            -132: Fromages
            -133: Desserts
        -14: Pains & Pâtisseries
            -140: Autres
            -141: Pains
            -142: Pâtisseries
        -15: Epicerie sucrée
            -150: Autres
            -151: Muesli
            -152: Gâteaux
            -153: Chocolats
        -16: Epicerie salée
            -160: Autres
            -161: Conserves
            -162: Plats cuisinés
            -163: Apéritifs
            -164: Céréales
            -165: Huiles, vignaires & condiment
            -166: Sauces
        -17: Surgelés
    -2: Habillement
        -20: Autres
            -201: Léo
            -202: Lulu
            -203: Lou
            -204: Zoé
        -21: Vêtements:
            -211: Léo
            -212: Lulu
            -213: Lou
            -214: Zoé
        -22: Chaussures
            -221: Léo
            -222: Lulu
            -223: Lou
            -224: Zoé
    -3: Logement
        -30: Autres
        -31: Loyer
        -32: Assurance
        -33: Energie
            -330: Autres
            -331: Electricité
            -332: Gaz
        -34: Travaux courant
        -35: Produit entretient
        -36: Linge de maison
    -4: Equipement
        -40: Autres
        -41: Meubles
        -42: Gros électroménager
        -43: Petit électroménager
        -44: Informatique
        -45: Vaisselle
        -46: Outillage
        -47: Décorations
    -5: Transports
        -50: Autres
        -51: Voiture:
            -510: Autres
            -511: Essence
            -512: Entretient
            -513: Assurance
        -52: Transport en commun
            -520: Autres
            -521: Abonnements
            -522: Tickets
        -53: Autoroutes
    -6: Loisir et culture
        -60: Autres
        -61: Jeux et jouets
            -611: Lou
            -612: Zoé
        -62: Sports
        -63: Parcs
        -64: Livres
        -65: Spectacles et concerts
        -66: Tissus & co
    -7: Services
        -70: Autres
        -71: Service banquaire
            -710: Autres
            -711: Frais banquaire
            -712: Epargne
        -72: Télécommunication
            -720: Autres
            -721: Internet
            -722: Téléphone portable
    -8: Santé
        -80: Autres
        -81: Médecins & co
        -82: Pharmacie
        -83: Savons & co
        -84: Couches
        */

    signal back();

    MouseArea{
        anchors.fill: parent
        onClicked: {}
    }


    function loadCategory( cat ){
        console.debug("Load category", cat)

        d.currentCategoryID = cat


        var res = sql.getCategoryStats( cat )

        res.sub.sort( function(a, b){ return a.value - b.value } )
        res.sub.reverse()

        console.debug(JSON.stringify(res.sub,null,2))

        d.chartDoughnutData = res.sub
        chart_doughnut.repaint()

        catText.text = res.name

        var total = 0.0

        statModel.clear()
        for(var i=0; i<d.chartDoughnutData.length; i++){
            total += d.chartDoughnutData[i].value
        }

        totalText.text = total.toFixed(2) + "€"

        for(var i=0; i<d.chartDoughnutData.length; i++){
            var a = {}
            a.id = d.chartDoughnutData[i].id
            a.name = d.chartDoughnutData[i].name
            a.total = d.chartDoughnutData[i].value
            a.percent = (100*d.chartDoughnutData[i].value/total)
            a.color = d.chartDoughnutData[i].color
            if(a.total>=0)
                statModel.append( a )
            //console.debug(JSON.stringify(a,null,2))
        }
    }

    ListModel{
        id: statModel
    }

    QtObject{
        id: d
        property int currentCategoryID: -1
        property var chartDoughnutData : [{
                value: 30,
                color: "#F7464A"
            }, {
                value: 50,
                color: "#E2EAE9"
            }, {
                value: 100,
                color: "#D4CCC5"
            }, {
                value: 40,
                color: "#949FB1"
            }, {
                value: 120,
                color: "#4D5360"
            }]
    }

    Rectangle {
        id: toolbar
        height: 50
        anchors.top: parent.top
        width: parent.width
        color: "#000000"

        Image {
            id: arrow
            source: "qrc:/images/left-arrow"
            anchors.left: toolbar.left
            anchors.leftMargin: 20
            anchors.verticalCenter: toolbar.verticalCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(d.currentCategoryID<0)
                        back()
                    else{
                        if(d.currentCategoryID<10)
                            loadCategory( -1 )
                        else
                            loadCategory( Math.floor( d.currentCategoryID / 10 ) )
                    }
                }
            }
        }

        Text {
            id: catText
            anchors.horizontalCenter: toolbar.horizontalCenter
            anchors.verticalCenter: toolbar.verticalCenter
            color: "#ffffff"
            font.family: "Abel"
            font.pointSize: 28
            text: qsTr("All")
        }
    }

    Rectangle{
        id: legend
        width: parent.width;
        height: parent.height / 5
        anchors.top: toolbar.bottom

        Grid{
            columns: 2
            spacing: 2
            anchors.fill: parent

            Repeater{
                model: statModel.count

                Rectangle{
                    width: (parent.width / 2) -1
                    height: childrenRect.height

                    Row{
                        spacing: 10
                        anchors.leftMargin: 5
                        anchors.left: parent.left
                        Rectangle{ color: statModel.get(index).color; height: catName.height * 0.75; width: height; anchors.verticalCenter: parent.verticalCenter}

                        Text{
                            id: catName
                            text: statModel.get(index).name + ": " + statModel.get(index).total.toFixed(2) + "€ (" + statModel.get(index).percent.toFixed(1) +"%)"
                        }
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: loadCategory( statModel.get(index).id  )
                    }
                }
            }
        }
    }



    Chart {
        id: chart_doughnut;

        anchors.top: legend.bottom
        anchors.bottom: parent.bottom

        width: parent.width;
        //height: 2*parent.height / 3

        //anchors.bottom: parent.bottom
        chartAnimated: true;
        chartAnimationEasing: Easing.OutElastic;
        chartAnimationDuration: 1000;
        chartData: d.chartDoughnutData;
        chartType: Charts.ChartType.DOUGHNUT;

        Text{
            id: totalText
            anchors.centerIn: parent
        }
    }




    Component.onCompleted: {
        loadCategory( -1 )

        //console.debug( JSON.stringify( d.chartDoughnutData, null, 2 ) )
    }


}
