//: Playground - noun: a place where people can play

import UIKit


class Person {
    let name :String
    var apartment: Apartment?
    var property: Apartment?

    init(name: String) {
        self.name = name
        print("\(name) is being initialized.")
    }
    
    deinit {
        print("\(name) is being deinitialized.")
    }
}


class Apartment {
    let unit :String
    var tenant: Person?
    unowned let owner: Person
    //和strong reference相比，unowned reference只有一个特别：不会引起对象引用计数的变化。unowned reference用于解决成员不允许为nil的reference cycle。

    init(unit: String, owner: Person) {
        self.unit = unit
        self.owner = owner
        print("Apartment \(unit) is being initialized.")
    }
    
    deinit {
        print("Apartment \(unit) is being deinitialized.")
    }
}

//: Strong reference
var ref1 :Person?
var ref2 :Person?


ref1 = Person(name: "Mars")

// count = 2
ref2 = ref1
// count = 1
ref1 = nil
// count = 0
// Mars is being deinitialized.
ref2 = nil   // is being deinitialized 销毁时调用

var mars :Person? = Person(name: "Mars")

var apt11: Apartment? = Apartment(unit: "11", owner: mars!)

mars!.apartment = apt11
// mars.count = 2
apt11!.tenant = mars

//这时，尽管我们把mars和apt11设置为nil，Person和Apartmetn的deinit也不会被调用了。
//因为它们的两个member（apartment和tenant）是一个strong reference，指向了彼此，让对象仍旧“存活”在内存里。
//但是，mars和apt11已经被设置成nil，我们也已经无能为力了。这就是类对象之间的reference cycle。
mars = nil
apt11 = nil


/*处理对象reference cycle的三种方式
    1:  weak var tenant: Person?
    2:  unowned let
    3:  unowned reference和implicitly unwrapped optional配合在一起，用于解决引起reference cycle的两个成员都不允许为nil的情况。

 */

class Country {
    let name: String
    var capital: City! // default to nil
    
    init(name: String, capitalName: String) {
        self.name = name
        // Syntax Error!!!
        self.capital = City(name: capitalName, country: self)
    }
    deinit {
        print("Country \(name) is being deinitialized.")
    }
}

class City {
    let name: String
    unowned let country: Country
    
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
    deinit {
        print("City \(name) is being deinitialized.")
    }
}

var cn: Country? = Country(name: "China", capitalName: "Beijing")
var bj: City? = City(name: "Beijing", country: cn!)

cn = nil
bj = nil

/*
 要想构建City时，让Swift认为Country已经构造完，唯一的做法就是captical有一个默认值nil。至此，对于Capital，我们有了两个看似冲突的需求：
 
 对Country的用户来说，不能让他们知道capital是一个optional；
 对Country的设计者来说，它必须像Optional一样有一个默认的nil；
 而解决这种冲突唯一的办法，就是把capital定义为一个Implicitly Unwrapped Optional (隐式解析可选)。
 */

/*处理closure和类对象之间的reference cycle*/

class HTMLElment {
    let name: String
    let text: String?
    
    //“lazy可以确保一个成员只在类对象被完整初始化过之后，才能使用。”
    lazy var asHTML: (Void) -> String = {
        // text
        // Capture list  由于HTMLElement没有了strong reference，因此它会被ARC释放掉，进而asHTML引用的closure也会变成“孤魂野鬼”，ARC当然也不会放过它。因此，closure和类对象间的循环引用问题就解决了。
        
        //在这里，关于closure capture list，我们要多说两点：
        //如果closure带有完整的类型描述，capture list必须写在参数列表前面；
        //如果我们要在capture list里添加多个成员，用逗号把它们分隔开；
        
        [unowned self /*, other capture member*/] () -> String in
        if let text = self.text {
            return "<\(self.name)>\(self.text)</\(self.name)>"
        }
        else {
            return "<\(self.name)>"
        }
    }
    //h1是我们定义的strong reference。Closure作为一个引用类型，它有自己的对象，因此asHTML也是一个strong reference。
    //由于asHTML“捕获”了HTMLElement的self，因此HTMLElement的引用计数是2。
    //当h1为nil时，asHTML对closure的引用和closure对self的“捕获”就形成了一个reference cycle。
    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }
  
    deinit {
        print("\(self.name) is being deinitialized")
    }
}

var h1: HTMLElment? = HTMLElment(name: "h1", text: "Title")
h1?.asHTML
//“当一个类中存在访问数据成员的closure member时，务必要谨慎处理它有可能带来的reference cycle问题。”
h1 = nil

