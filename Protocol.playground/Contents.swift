//: Playground - noun: a place where people can play

import UIKit

/*
 作为Swift中的一种自定义类型，和struct，class、enum不同，我们使用protocol来定义某种约定，而不是某一个具体的类型，这种约定通常用于表示某些类型的共性。
 */
protocol Engine{
    
    var cylinder : Int{ get set} //可读写
    var capacity: Double { get }
    func start()
    func stop()
    /*
     当protocol中的方法带有参数时，参数是不能有默认值的。如果我们希望把“提供有默认参数版本的方法”也作为一种约定，我们只能像下面这样单独定义一个不带任何参数的方法。例如我们要添加一个生成引擎名称的方法：
     */
    func getName(prefix: String) //默认不能添加默认值
    func getName()
}

/*
 protocol也是可以继承的
 
 和class的继承类似，protocol也支持继承，用于表示“约定A” is A "约定B"这样的语意。
 */
protocol TurborEngine:Engine{
    func startTurbo()
    func stopTurbo()
}

protocol Motor {
    var power: Double { get set }
}



class V8 : TurborEngine , Motor{
    
    var cylinder = 8
    private var innerCapacity: Double = 4.0
    var power: Double = 20
    var capacity: Double {
        get {
            return self.innerCapacity
        }
        set {
            self.innerCapacity = newValue
        }
    }
    func start(){print("Engine started")}
    
    func stop(){print("Engine stopped")}
    
    func getName(prefix: String){
        print("Engine V8")
    }
    
    func getName(){
        print("Engine V8")
    }
    
    func startTurbo() {
        print("Engine Turbo started")
    }
    
    func stopTurbo() {
        print("Engine Turbo stopped")
    }
}

let v8L40 = V8()
v8L40.cylinder
v8L40.cylinder = 8
v8L40.capacity
v8L40.capacity = 8


/*使用标准库中的protocol*/

let a: Int = 10
let b: Int = 10

let d1: Double = 3.14
let d2: Double = 3.14

struct Rational {
    var numerator: Int
    var denominator: Int
}


let oneHalf = Rational(numerator: 1, denominator: 2)
let zeroPointTwo = Rational(numerator: 1, denominator: 2)

// 下边这样比较会出错
//if oneHalf == zeroPointTwo {
//}

extension Rational :Equatable{}

func == (lhs:Rational ,rhs:Rational) -> Bool {
    let equalNumerator = lhs.numerator == rhs.numerator
    let equalDenominator = lhs.denominator == rhs.denominator
     return equalNumerator && equalDenominator
}

extension Rational: Comparable {}
func < (lhs: Rational, rhs: Rational) -> Bool {
    let lQuotient =
        Double(lhs.numerator) / Double(lhs.denominator)
    let rQuotient =
        Double(rhs.numerator) / Double(rhs.denominator)
    
    return lQuotient < rQuotient
}

var rationals: Array<Rational> = []

for i in 1...10 {
    var r = Rational(numerator: i, denominator: i+1)
    rationals.append(r)
}

print("Max in rationals: \(rationals.max()!)")
print("Min in rationals: \(rationals.min()!)")
rationals.starts(with: [oneHalf])
rationals.contains(oneHalf)

/*
 CustomStringConvertible只有一个约定：定义一个名为description的属性。这样，上面的print结果就变成了这样：
 */
extension Rational : CustomStringConvertible {
    var description: String {
        return "\(self.numerator) / \(self.denominator)"
    }
}


let maybe : Bool? = false
if maybe! {
    // executed because `maybe` is an optional having a value (false),
    // not because it is true
}

extension Rational: Hashable {
    var hashValue: Int {
        let v = Int(String(self.numerator) + String(self.denominator))!
        return v
    }
}

oneHalf.hashValue


var dic: Dictionary<Rational, String> = [oneHalf: "1/2"]

var rSet: Set<Rational> = [oneHalf]

/*认识protocol extension*/

protocol Flight {
    var delay: Int { get }
    var normal: Int { get }
    var flyHour: Int { get }
    
//    func delayRate() -> Double
}


extension Flight {
    var totalTrips: Int {
        return delay + normal
    }
    func delayRate() -> Double {
        return Double(delay) / Double(totalTrips)
    }
}

/*
 扩展一个protocol看似和扩展其它自定义类型没有太大区别，都是使用extension关键字，加上要扩展的类型的名字。
 但是，和定义protocol不同，我们可以在一个protocol extension中提供默认的实现。
 尽管此时我们还没有定义任何"遵从"Flight的类型，但是我们已经可以在extension中使用Flight的数据成员了。
 因为Swift编译器知道，任何一个"遵从"Fligh的自定义类型，一定会定义Flight约定的各种属性。
 */


struct A380: Flight {
    var delay: Int
    var normal: Int
    var flyHour: Int
    
    func delayRate() -> Double {
        return 0.1
    }
}

/*
 extension即可以为protocol添加额外的功能，又可以为已有的方法提供默认实现。
 但是，这两种行为，却有着细微的差别，简单来说：
    通过extension添加到protocol中的内容，不算做protocol约定
 */
let flight1 = A380(delay: 300, normal: 700, flyHour: 5 * 365 * 24)
flight1.totalTrips // 1000
flight1.delayRate() // 0.3
(flight1 as Flight).delayRate() // 0.1

/*然后，无论flight1的类型是Flight还是A380，我们可以看到delayRate()的输出都将变成0.1：*/
/*
     这是因为当我们在Flight中注释掉delayRate()时，它就不在是Flight约定的一部分了。
     在extension中实现的delayRate()只不过是为Flight提供的一个便利功能。
     既然delayRate()不再是约定，Swift编译器也不会"感知"到A380对delayRate()的重定义，而只是把delayRate()理解为是A380定义的一个普通的方法。
     因此，我们把flight1的类型转换Flight时，Swift就会调用Flight版本的delayRate了。
     实际上，Flight和A380中的delayRate()没有任何关系。
 */

protocol OperationalLife {
    var maxFlyHours: Int { get }
}

extension Flight where Self: OperationalLife {
    func isInService() -> Bool {
        return self.flyHour < maxFlyHours
    }
}

/*
     where表示我们要进行一个type contraints，Self表示"最终遵从protocol的类型"（在我们的例子里，也就是A380）。
     所以整个表达式的含义就是当某个类型同时遵从OperationalLife和Flight时，扩展Flight，并提供isInService方法。
 */

extension A380: OperationalLife {
    var maxFlyHours: Int {
        return 18 * 365 * 24
    }
}

let flight2 = A380(delay: 300, normal: 700, flyHour: 5 * 365 * 24)
flight2.isInService() // true

/*
     之所以类型会越来越复杂，是因为我们在类方法里不断暴露的实现细节和类型自身要表达的功能之间的耦合度越来越强造成的。
     对于CancellableFlight来说，为什么我们要把"延误总次数"和"总飞行次数"的计算细节暴露给CancellableFlight呢？CancellableFlight只用于表示一个可以被延误的航班，它完全没必要理解那些总次数的计算细节。
     而解决"全功能型"类型的方法，就是把这些和类型无关的细节从类型定义中去掉，让它们变成对类型的一种修饰。这就是protocol oriented programming要表达的含义。
 */

/*为了解决"全功能型"类型的问题，我们来看protocol的做法。为了让Flight支持可取消的特性*/
protocol Cancellable {
    var cancel: Int { get }
}

extension Flight where Self: Cancellable {
    func delayRate() -> Double {
        let totalDelay = Double(delay + cancel)
        let total = Double(delay + normal + cancel)
        
        return  totalDelay / total
    }
}


struct A381: Flight, Cancellable {
    var delay: Int
    var normal: Int
    var flyHour: Int
    var cancel: Int
}


