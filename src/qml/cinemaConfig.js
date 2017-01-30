function config(name) {
    switch(name) {
    case "khabarovsk" : return {
            id: 1,
            logo: "/src/images/khabarovsk.png",
            logoMargin: 48,
        }
    case "atmosfera": return {
            id: 2,
            logo: "/src/images/atmosfera.png",
            logoMargin: 47,
        }
    case "drujba": return {
            id: 3,
            logo: "/src/images/drujba.png",
            logoMargin: 47,
        }
    case "forum": return {
            id: 4,
            logo: "/src/images/forum.png",
            logoMargin: 50,
        }
    }
}
