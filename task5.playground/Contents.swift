import UIKit




struct Num<Element>{
   func sum(_ first : Element, _ second : Element)-> Element?{
        return nil
    }
}
 
extension Num where Element == String{
    func sum(_ first : Element, _ second : Element)-> Element{
           return first + second
       }
}

extension Num where Element : Numeric{
    func sum(_ first : Element, _ second : Element)-> Element{
           return first + second
       }
}








var tmp3 = Num<Int>()
tmp3.sum(123, 321)

var tmp4 = Num<Double>()
tmp4.sum(123.11, 321.21)

var tmp5 = Num<String>()
tmp5.sum("123.11", "321.21")

var tmp6 = Num<Bool>()
tmp6.sum(true, false)




struct Num2<Element, SetElement>{
   func sum(_ first : Element, _ second : Element)-> Element?{
        return nil
    }
}
 
 extension Num2 where Element == Set<SetElement>{
     
     func sum(_ first : Element, _ second : Element)-> Element{
         var res = first
         for tmp in second {
             res.insert(tmp)
         }
         return res
     }
 }

 
var tmp7 = Num2<Set<Int>, Int>()
tmp7.sum([5,6] , [1,2,3,4,8,7])
 
 




//все сделанное после этого делалось до лекции о дженериках - длинная арифметика с дробями и системами счисления до 16

func plus(s1:String, s2:String, osn : Int)->String{ //внешняя функция
    guard osn>1 , osn<=16 else {
        return "Поддерживаются только системы считсления с основанием 16 или менее."
    }
    
    var aQuads:Array<Int> = []
    var aNegative = false      //думал сделать еще отрицательные значения
    var aDotPosition = -1
    
    var bQuads:Array<Int> = []
    var bNegative = false
    var bDotPosition = -1
    
//    guard getQuads(from: s1, osn: osn) != nil else {return "Error"}
    guard let tmp : ([Int],Bool,Int) = getQuads(from: s1, osn: osn) else {
        print("1st string conains wrong symbol")
        return "Error"
    }
//    guard tmp != nil else {return "Error"}
    aQuads = tmp.0
    aNegative=tmp.1
    aDotPosition = tmp.2
    
    guard let tmp2 : ([Int],Bool,Int) = getQuads(from: s2, osn: osn) else {
        print("2nd string conains wrong symbol")
        return "Error"
    }
//     guard tmp2 != nil else {return "Error"}
    bQuads = tmp2.0
    bNegative=tmp2.1
    bDotPosition = tmp2.2
    
    
    guard let res: String = add(a:aQuads, aDotPosition: aDotPosition ,b:bQuads, bDotPosition: bDotPosition, osn: osn) else {return "add error"}
    //    guard res != nil else {return "add error"}
    return(res)
}



func superPlus(a: [Int], b:[Int], osn:Int) -> ([Int],Bool){ //сложение массивов
    
    var resBool = false
    var res : [Int] = []
    
    let aIntCount = a.count
    let bIntCount = b.count
    let count =  aIntCount>=bIntCount ? aIntCount : bIntCount
    var add = 0 ;
    for tickMark in stride(from: 0, to: count, by: 1) {  //пробегаем по всему массиву
        let tt = (aIntCount-tickMark > 0 ? a[aIntCount-tickMark-1] : 0) //начиная с конца, складываем элементы массива
        let tt2 = (bIntCount-tickMark > 0 ? b[bIntCount-tickMark-1] : 0)
        var tt3 = tt2 + tt + add
        add=0
        
        if tt3 > osn-1 {  //если получено значение больше основания -1 переносим единичку в следующий разряд
            tt3 -= osn
            add=1
        }
        res.append(tt3)
    }
    
    if add==1 {
        resBool = true
    }
    
    return (res,resBool)
}


func add(a: [Int],aDotPosition : Int,  b:[Int], bDotPosition: Int, osn:Int) -> String?{ //cкладываем массив интов по основанию и с позицией точки -> получаем строку
    
    //
    let arraySliceA = a[(aDotPosition >= 0 ? aDotPosition : a.count-1) ... a.count-1]
    var newFractionalArrayA = Array((aDotPosition >= 0 ? arraySliceA : [0]))
    let arraySliceB =  b[(bDotPosition >= 0 ? bDotPosition : b.count-1) ... b.count-1]
    var newFractionalArrayB = Array((bDotPosition >= 0 ? arraySliceB : [0]))
    
    let arrayRealSliceA = a[0 ... (aDotPosition >= 0 ? aDotPosition-1 : a.count-1)]
    let newRealArrayA = Array(arrayRealSliceA)
    let arrayRealSliceB =  b[0...(bDotPosition >= 0 ? bDotPosition-1 : b.count-1)]
    let newRealArrayB = Array(arrayRealSliceB)
    
    if newFractionalArrayA.count>newFractionalArrayB.count {
        for _ in stride(from: 0, to: newFractionalArrayA.count-newFractionalArrayB.count, by: 1){
            newFractionalArrayB.append(0)
        }
    }else{
        for _ in stride(from: 0, to: newFractionalArrayB.count-newFractionalArrayA.count, by: 1){
            newFractionalArrayA.append(0)
        }
    }
    
    var real : ([Int],Bool) = superPlus(a : newRealArrayA, b :newRealArrayB,osn : osn)
    let fractional : ([Int],Bool)
    if  aDotPosition>=0 || bDotPosition >= 0 {
        fractional = superPlus(a : newFractionalArrayA, b :newFractionalArrayB,osn : osn)
    }else {
        fractional = ([0],false)
    }
    
    if real.1 {
        real.0.append(1)
    }
    
    var varReal : [Int] = reverseArray(a: real.0)
    let varFractional : [Int] = reverseArray(a: fractional.0)
    
    if fractional.1 {
        real = superPlus(a: varReal, b: [0,1], osn: osn)
    }
    
    if real.1 , fractional.1 {
        real.0.append(1)
    }
    
    varReal = reverseArray(a: real.0)
    
    var resStr : String = ""
    guard let realStr = fillResStringFromArray(from: varReal), let factionalStr = fillResStringFromArray(from: varFractional)else {return nil}
    resStr = realStr + "." + factionalStr
    return resStr
}

func fillResStringFromArray(from : [Int]) -> String? { //Заполняем строку из массива
    var resStr: String = ""
    for tickMark in stride(from: 0, to: from.count, by: 1){
        let tmpChar : String?
        tmpChar = getCharFromIntWithOsn(c: from[tickMark],osn: osn)
        guard tmpChar != nil else{ return nil}
        resStr += tmpChar!
    }
    return resStr
}

func reverseArray(a:[Int])->[Int]{  //разворачиваем массив
    var real : [Int] = []
    for tickMark2 in stride(from: a.count-1, to: -1, by: -1){
        real.append(a[tickMark2])
    }
    return real
}


private func getQuads(from: String, osn: Int)->([Int],Bool,Int)?{//преобразует строку в картеж (массив интов, отрицательное ли число, позиция запятой)
    var first = true
    var negative = false
    var firstDot = -1
    var j=0
    var digits:Array<Int> = []
    for c in from {
        if first {
            first = false
            if c == "-" {
                negative = true
            }
        }
        guard let i = Int(String(c)) else{
            
            if c == "."{
                guard firstDot == -1 else {return nil}
                if j == 0 {
                    return nil
                }
                firstDot=j
                continue
            }
            let tmp : Int? = getIntFromStringWithOsn(from: String(c),osn:osn)
            guard tmp != nil else {return nil}
            j+=1
            digits.append(tmp!)
            continue
        }
        guard i <= osn else {
            print("Readet Int more then curent osn")
            return nil
        }
        
        digits.append(i)
        j+=1
    }
    return (digits,negative,firstDot)
}
func getIntFromStringWithOsn(from: String, osn: Int)->Int?{  // переводим число в букву для систем счисления до 16
    switch from{
    case "A":
        if osn>10{
            return 10
        }
        else {return nil}
    case "B":
        if osn>11{
            return 11
        }
        else {return nil}
    case "C":
        if osn>12{
            return 12
        }
        else {return nil}
    case "D":
        if osn>13{
            return 13
        }
        else {return nil}
    case "E":
        if osn>14{
            return 14
        }
        else {return nil}
    case "F":
        if osn>15{
            return 15
        }
        else {return nil}
    default:
        return nil
    }

}

func getCharFromIntWithOsn(c: Int, osn: Int)->String?{  // переводим ,букву в число для систем счисления до 16
    guard c <= 16 else{return nil}
    switch c {
    case 10:
        if osn>10{
            return "A"
        }
        else {return nil}
    case 11:
        if osn>11{
            return "B"
        }
        else {return nil}
    case 12:
        if osn>12{
            return "C"
        }
        else {return nil}
    case 13:
        if osn>13{
            return "D"
        }
        else {return nil}
    case 14:
        if osn>14{
            return "E"
        }
        else {return nil}
        
    case 15:
        if osn>15{
            return "F"
        }
        else {return nil}
    default:
        return String(c)
    }
    
}



let osn = 16
let s1 = "121AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.A1211112223332211234455678865"
let s2 = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAAA.F123432122344121242124"
let res = plus(s1: s1, s2: s2, osn: osn)
print("--------------------------")
if res != "Error"{ print("\(s1) + \(s2) =  /n \(res) in \(osn)")
}else {print("\(res)")}

