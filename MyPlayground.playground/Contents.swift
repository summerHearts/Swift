//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func printName() {
    print("My name is kenvin")

}

printName()


func mul(m:Int,n:Int){
    print( m * n)
}


mul(m: 2, n: 3)

//理解参数的两种名称

//在Swift里，函数的参数实际上有两个名字，一个用于在定义函数的时候使用，叫做argument name，一个用于在调用函数时使用，叫做argument label

//但是，其实我并不是很喜欢这个称呼，因为我经常搞混name和label，谁用在定义，谁用在调用。因此，我更喜欢管定义的时候使用的名称叫做internal name，表示在函数内部使用；而管调用的时候使用的名称叫做external name，表示在函数外部使用。而在下面的例子里，我也会使用这两个名字。

//在我们的mul例子中，m和n，就是internal name，默认情况下，如果不特别定义external

func mul(multiplicand m: Int, of n: Int) {
    print(m * n)
}

mul(multiplicand: 2, of: 3) // 6


func mul(_ m: Int, of n: Int) {
    print(m * n)
}

mul(2, of: 3)


func muls(_ m: Int, of n: Int = 1) {
    print(m * n)
}

muls(2) // 2

//numbers: Int...的形式，表示函数可以接受的Int参数的个数是可变的。实际上，numbers的类型，是一个Array<Int>，因此，为了计算乘积，我们直接使用Array类型的reduce方法就好了
func mul(_ numbers: Int ...) {
    let arrayMul = numbers.reduce(1, *)
    print("mul: \(arrayMul)")
}

mul(2, 3, 4, 5, 6, 7) // 5040

//inout关键字修饰一下参数的类型，明确告诉Swift编译器我们要修改这个参数的值：
func mul(result: inout Int, _ numbers: Int ...) {
    result = numbers.reduce(1, *) // !!! Error here !!!
    print("mul: \(result)")
}

var result = 0
mul(result: &result, 2, 3, 4, 5, 6, 7)
result // 5040

//-> Type的方式，在参数列表后面定义返回值。然后，就可以用mul的返回值，来定义变量了：
func mulss(_ numbers: Int ...) -> Int {
    return numbers.reduce(1, *)
}

let results = mulss(2, 3, 4, 5, 6, 7) // 5040
results

func div(a: Int, b: Int) -> Int {
    return a / b
}

func mul(m: Int, of n: Int) -> Int {
    return m * n
}

func calc<T>(_ first: T,
          _ second: T,
          _ fn: (T, T) -> T) -> T {
    return fn(first, second)
}

calc(2, 3, mul) // 6
calc(2, 3, div) // 0

func mulb(_ a: Int) -> (Int) -> Int {
    func innerMul(_ b: Int) -> Int {
        return a * b
    }
    
    return innerMul
}

let mul2By = mulb(2)
mul2By(3) // 6


//---函数和Closure真的是不同的类型么？---------------------------------------

//提起closure，如果你有过其他编程语言的经历，你可能会立即联想起一些类似的事物，例如：匿名函数、或者可以捕获变量的一对{}，等等。但实际上，我们很容易搞混两个概念：Closure expression和Closure。

func square(_ n: Int) -> Int {
    return n * n
}

//用于定义squareExpression的{}就叫做closure expression，它只是把函数参数、返回值以及实现统统写在了一个{}里。

//没错，此时的{}以及squareExpression并不能叫closure，它只是一个closure expression。那么，为什么要有两种不同的方式来定义函数呢？最直接的理由就是，为了写起来更简单。Closure expression可以在定义它的上下文里，被不断简化，让代码尽可能呈现出最自然的语义形态。

let squareExpression = { (n: Int) -> Int in
    return n * n
}
//用于定义squareExpression的{}就叫做closure expression，它只是把函数参数、返回值以及实现统统写在了一个{}里。

square(2)
squareExpression(2) // 4

let numbers = [1, 2, 3, 4, 5]
numbers.map(square) // [1, 4, 9, 16, 25]
numbers.map(squareExpression) // [1, 4, 9, 16, 25]

numbers.map({ (n: Int) -> Int in
    return n * n
})

//Swift可以根据numbers的类型，自动推导出map中的函数参数以及返回值的类型，因此，我们可以在closure expression中去掉它：
numbers.map({ n in return n * n })

//如果closure expression中只有一条语句，Swift可以自动把这个语句的值作为整个expression的值返回，因此，我们还可以去掉return关键字：
numbers.map({ n in n * n })

//如果你觉得在closure expression中为参数起名字是个意义不大的事情，我们还可以使用Swift内置的$0/1/2/3/4这样的形式作为closure expression的参数替代符，这样，我们连参数声明和in关键字也都可以省略了：
numbers.map({ $0 * $0 })

//如果函数类型的参数在参数列表的最后一个，我们还可以把closure expression写在()外面，让它和其它普通参数更明显的区分开：
numbers.map() { $0 * $0 }

//如果函数只有一个函数类型的参数，我们甚至可以在调用的时候，去掉()：

numbers.map { $0 * $0 }

//你就应该知道当我们把closure expression用在它的上下文里，究竟有多方便了，相比一开始的定义，或者单独定义一个函数，然后传递给它，都好太多。但事情至此还没结束，相比这样：

numbers.sorted(by: { $0 > $1 }) // [5, 4, 3, 2, 1]
//Closure expression还有一种更简单的形式：

numbers.sorted(by: >) // [5, 4, 3, 2, 1]


//closure expression还有一个副作用，就是默认情况下，我们无法忽略它的参数，编译器会对这种情况报错。来看个例子，如果我们要得到一个包含10个随机数的Array，最简单的方法，就是对一个CountableRange调用map方法：

//(0...9).map { arc4random() } // !!! Error in swift !!!

//这样看似很好，但是由于map的函数参数默认是带有一个参数的，在我们的例子里，表示range中的每个值，因此，如果我们在整个closure expression里都没有使用这个参数，Swift编译器就会提示我们下面的错误：

(0...9).map { _ in arc4random() }

//究竟什么是Closure？说的通俗一点，一个函数加上它捕获的变量一起，才算一个closure。来看个例子：

func makeCounter() -> () -> Int {
    var value = 0
    
    return {
        value += 1
        
        return value
    }
}

let counter1 = makeCounter()
let counter2 = makeCounter()

(0...2).forEach { _ in print(counter1()) } // 1 2 3
(0...5).forEach { _ in print(counter2()) } // 1 2 3 4 5 6


func makeCounters() -> () -> Int {
    var value = 0
    func increment() -> Int {
        value += 1
        return value
    }
    
    return increment
}


let counter3 = makeCounter()
let counter4 = makeCounter()

(0...2).forEach { _ in print(counter3()) } // 1 2 3
(0...5).forEach { _ in print(counter4()) } // 1 2 3 4 5 6

//总结：func和closure expression都可以用来定义函数，它们只是形式上的不同；另一方面，无论是用哪种方式定义了函数，一旦其捕获了变量，函数和它捕获变量的上下文环境一起，就形成了一个closure。



