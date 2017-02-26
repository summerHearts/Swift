//: Playground - noun: a place where people can play

import UIKit


enum RobotError :Error{
    case LowPower(Double)  //电量低
    case Overload(Double)  //超过负载
}

class Robot {
    var power = 1.0  //当前电量
    let maxLifting = 100.0 //表示它可以举起来的最大质量
    
    func action(command: Command) throws {
        switch command {
        case .PowerUp:
            guard self.power > 0.2 else {
                throw RobotError.LowPower(0.2)
            }
            
            print("Robot started")
        case let .Lifting(weight):
            guard weight <= maxLifting else {
                throw RobotError.Overload(maxLifting)
            }
            
            print("Lifting weight: \(weight) KG")
        case .Shutdown:
            print("Robot shuting down...")
        }
    }

}

//添加一些可以发送给Robot的命令
enum Command {
    case PowerUp
    case Lifting(Double)
    case Shutdown
}

/*在action的实现里，当处理.PowerUp命令时，我们使用了guard确保Robot电量要大于20%，
  否则，我们使用throw RobotError.LowPower(0.2)的方式抛出了一个异常（throw出来的类型必须是ErrorType）。
 */

/*处理.Lifting命令时，我们读取了.Liftting的associated value，
 如果要举起的质量大于maxLifting，则throw RobotError.Overload(maxLifting)。
 */

//通常，guard和throw配合在一起，可以让我们的代码变的更加简洁。

func working(robot: Robot) throws  -> Int {
    
    defer {
        try! robot.action(command: Command.Shutdown)
    }

    
    do {
        try robot.action(command: Command.PowerUp)
        try robot.action(command: Command.Lifting(52))
    }
    catch let RobotError.LowPower(percentage) {
        print("Low power: \(percentage)")
    }
    catch let RobotError.Overload(maxWeight) {
        print("Overloading, max \(maxWeight) KG is allowd")
    }
    
    return 0
    
}

let iRobot = Robot()

try? working(robot: iRobot)
let a = try? working(robot: iRobot)
print("value: \(a)\n type: \(type(of: a))")




func divide(dividend: Double,by: Double, err: inout String?) -> Double  {
    if by == 0 {
        err = "Cannot divide by zero"
        return -1
    }
    else {
        return dividend / by
    }
}

var err: String?

var result = divide(dividend: 4, by: 2, err: &err)

if let err = err {
    print("\(err)")
}
else {
    print("\(result)")
}

enum Result<T> {
    case Success(T)
    case Failure(String)
    
    func map<P> (f: (T) -> P) -> Result<P> {
        switch self {
        case .Success(let value):
            return .Success(f(value))
        case .Failure(let err):
            return .Failure(err)
        }
    }
    
    func flatMap<P> (f: (T) -> Result<P>) -> Result<P> {
        switch self {
        case .Success(let value):
            return f(value)
        case .Failure(let err):
            return .Failure(err)
        }
    }
}

func newDivide(dividend: Double, by: Double) -> Result<Double> {
    if by == 0 {
        return Result.Failure("Cannot divided by zero")
    }
    else {
        return Result.Success(dividend / by)
    }
}

let r = newDivide(dividend: 4, by: 2)

switch r {
case let .Success(value):
    print("\(value)")
case let .Failure(error):
    print("\(error)")
}



func numSqrt(num: Double) -> Result<Double> {
    if num < 0 {
        return Result.Failure("number cannot be negative")
    }
    else {
        return .Success(sqrt(num))
    }
}

func num2String(num: Double) -> String {
    let s = String(format: "%.10f", num)
    return s
}


let r3 = r.flatMap(f: numSqrt).map(f: num2String)
let r4 = r.map(f: sqrt).map(f: { String(format: "%.10f", $0) })


