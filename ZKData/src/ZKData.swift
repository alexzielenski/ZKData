//
//  ZKData.swift
//  ZKData
//
//  Created by Alex Zielenski on 10/6/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

import Foundation
import ObjectiveC

//MARK: Operators
/** Shorthand for adjusting the current offset in
* the reading of the NSData for nextInt, etc.
**/
infix operator <- { associativity left }
infix operator +> { associativity left }
infix operator >| { associativity left }

public func +>(left: NSData, right: Int) -> NSData {
    left.currentOffset += right
    return left
}

public func <-(left: NSData, right: Int) -> NSData {
    left.currentOffset -= right
    return left
}

public func >|(left: NSData, right: Int) -> NSData {
    left.currentOffset = right
    return left
}

private var kOffsetKey = 0

public extension UInt8 {
    public var signed: Int8 {
        get {
            return Int8(self)
        }
        mutating set {
            self = UInt8(newValue)
        }
    }
    mutating func swap() -> UInt8 {
        return self
    }
}

public extension UInt16 {
    public var signed: Int16 {
        get {
            return Int16(self)
        }
        mutating set {
            self = UInt16(newValue)
        }
    }
    mutating func swap() -> UInt16 {
        self = CFSwapInt16(self)
        return self
    }
}

public extension UInt32 {
    public var signed: Int32 {
        get {
            return Int32(self)
        }
        mutating set {
            self = UInt32(newValue)
        }
    }
    mutating func swap() -> UInt32 {
        self = CFSwapInt32(self)
        return self
    }
}

public extension UInt64 {
    public var signed: Int64 {
        get {
            return Int64(self)
        }
        mutating set {
            self = UInt64(newValue)
        }
    }
    mutating func swap() -> UInt64 {
        self = CFSwapInt64(self)
        return self
    }
}

//MARK: Unsigned Conversions
/** Conversion from primitive types to their unsigned
* compliment using dot syntax. Watch out for overflows
**/
public extension Int8 {
    public var unsigned: UInt8 {
        get {
            return UInt8(self)
        }
        mutating set {
            if newValue > UInt8(INT8_MAX) {
                self = Int8(INT8_MAX)
            } else {
                self = Int8(newValue)
            }
        }
    }
    
    mutating func swap() -> Int8 {
        return self
    }
}

public extension Int16 {
    public var unsigned: UInt16 {
        get {
            return UInt16(self)
        }
        mutating set {
            if newValue > UInt16(INT16_MAX) {
                self = Int16(INT16_MAX)
            } else {
                self = Int16(newValue)
            }
        }
    }
    mutating func swap() -> Int16 {
        self.unsigned = CFSwapInt16(self.unsigned)
        return self
    }
}

public extension Int32 {
    public var unsigned: UInt32 {
        get {
            return UInt32(self)
        }
        mutating set {
            if newValue > UInt32(INT32_MAX) {
                self = Int32(INT32_MAX)
            } else {
                self = Int32(newValue)
            }
        }
    }
    
    mutating func swap() -> Int32 {
        self.unsigned = CFSwapInt32(self.unsigned)
        return self
    }
}

public extension Int64 {
    public var unsigned: UInt64 {
        get {
            return UInt64(self)
        }
        mutating set {
            if newValue > UInt64(INT64_MAX) {
                self = Int64(INT64_MAX)
            } else {
                self = Int64(newValue)
            }
        }
    }
    mutating func swap() -> Int64 {
        self.unsigned = CFSwapInt64(self.unsigned)
        return self
    }
}

//MARK: ZKData
/** Adds currentOffset property and ability to easily
* read common primitive types concisely with dot syntax
**/
public extension NSData {
    public var currentOffset: Int {
        get {
            var value = objc_getAssociatedObject(self, &kOffsetKey) as NSNumber?
            if let num = value {
                return num.longValue as Int
            }
            return 0
        }
        set {
            var val = newValue
            if val > self.length {
                val = self.length
            }
            
            if val < 0 {
                val = 0
            }
            
            let num = NSNumber(long: val)
            objc_setAssociatedObject(self, &kOffsetKey, num, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    // Subscript getters
    /** Cannot do setters due to limitations in Swift **/
    subscript(offset: Int) -> Int16 {
        get {
            return self.shortAtOffset(offset)
        }
    }
    
    subscript(offset: Int) -> Int32 {
        get {
            return self.intAtOffset(offset)
        }
    }
    
    subscript(offset: Int) -> Int64 {
        get {
            return self.longAtOffset(offset)
        }
    }
    
    subscript(offset: Int) -> Float {
        get {
            return self.floatAtOffset(offset)
        }
    }
    
    subscript(offset: Int) -> Float64 {
        get {
            return self.doubleAtOffset(offset)
        }
    }
    
    //MARK: next getters
    public var nextByte: Int8 {
        get {
            let value = byteAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    public var nextShort: Int16 {
        get {
            let value = shortAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    public var nextInt: Int32 {
        get {
            let value = intAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    public var nextLong: Int64 {
        get {
            let value = longAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    public var nextFloat: Float32 {
        get {
            let value = floatAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    public var nextDouble: Float64 {
        get {
            let value = doubleAtOffset(self.currentOffset)
            self +> sizeof(value.dynamicType)
            return value
        }
    }
    
    private func valueAtOffset<T>(type: T.Type, offset: Int) -> T {
        let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T) * 1)
        self.getBytes(pointer, range: NSMakeRange(offset, sizeof(T)));
        let value = pointer.memory
        pointer.destroy()
        return value
    }
    
    //MARK: Specific Offset Getters
    /** Used to get primitives at certain offsets **/
    public func byteAtOffset(offset: Int) -> Int8 {
        return valueAtOffset(Int8.self, offset: offset)
    }
    
    public func shortAtOffset(offset: Int) -> Int16 {
        return valueAtOffset(Int16.self, offset: offset)
    }
    
    public func intAtOffset(offset: Int) -> Int32 {
        return valueAtOffset(Int32.self, offset: offset)
    }
    
    public func longAtOffset(offset: Int) -> Int64 {
        return valueAtOffset(Int64.self, offset: offset)
    }
    
    public func floatAtOffset(offset: Int) -> Float32 {
        return valueAtOffset(Float32.self, offset: offset)
    }
    
    public func doubleAtOffset(offset: Int) -> Float64 {
        return valueAtOffset(Float64.self, offset: offset)
    }
    
    public func stringAtOffset(offset: Int, encoding: NSStringEncoding, length: Int) -> String {
        let pointer = UnsafeMutablePointer<UInt8>.alloc(length)
        self.getBytes(pointer, range: NSMakeRange(offset, length))
        
        return NSString(bytesNoCopy: pointer, length: length, encoding: encoding, freeWhenDone: true) as String
    }
    
}

private var kReplaceKey = 0

//MARK: ZKMutableData
/** Same as above except the client is able to insert/replace
* common primitives using dot syntax such as data.nextInt = 4
*
* if replaceMode is set to true, setting nextInt(etc.) will replace
* the bytes after the current offset, if it is false the int will
* be inserted into the current offset.
**/
public extension NSMutableData {
    // Dictates whether the set... methods will insert or replace
    public var replaceMode: Bool {
        get {
            var value = objc_getAssociatedObject(self, &kReplaceKey) as NSNumber?
            if let num = value {
                return num.boolValue
            }
            return false
        }
        set {
            let num = NSNumber(bool: newValue)
            objc_setAssociatedObject(self, &kReplaceKey, num, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    //MARK: next   setters
    override public var nextByte: Int8 {
        get {
            return super.nextByte
        }
        set {
            setByteAtOffset(newValue, offset: self.currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    override public var nextShort: Int16 {
        get {
            return super.nextShort
        }
        set {
            setShortAtOffset(newValue, offset: currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    override public var nextInt: Int32 {
        get {
            return super.nextInt
        }
        set {
            setIntAtOffset(newValue, offset: currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    override public var nextLong: Int64 {
        get {
            return super.nextLong
        }
        set {
            setLongAtOffset(newValue, offset: currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    override public var nextFloat: Float32 {
        get {
            return super.nextFloat
        }
        set {
            setFloatAtOffset(newValue, offset: currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    override public var nextDouble: Float64 {
        get {
            return super.nextDouble
        }
        set {
            setDoubleAtOffset(newValue, offset: currentOffset)
            self +> sizeof(newValue.dynamicType)
        }
    }
    
    //MARK: Set Values at Offsets
    private func setValueAtOffset<T>(type: T.Type, inout value: T, offset: Int) {
        var range = NSMakeRange(offset, sizeof(value.dynamicType))
        if replaceMode == false {
            range.length = 0
        }
        replaceBytesInRange(range, withBytes: &value, length: sizeof(value.dynamicType))
    }
    
    public func setByteAtOffset(value: Int8, offset: Int) {
        var val = value
        setValueAtOffset(Int8.self, value: &val, offset: offset)
    }
    
    public func setShortAtOffset(value: Int16, offset: Int) {
        var val = value
        setValueAtOffset(Int16.self, value: &val, offset: offset)
    }
    
    public func setIntAtOffset(value: Int32, offset: Int) {
        var val = value
        setValueAtOffset(Int32.self, value: &val, offset: offset)
    }
    
    public func setLongAtOffset(value: Int64, offset: Int) {
        var val = value
        setValueAtOffset(Int64.self, value: &val, offset: offset)
    }
    
    public func setFloatAtOffset(value: Float, offset: Int) {
        var val = value
        setValueAtOffset(Float.self, value: &val, offset: offset)
    }
    
    public func setDoubleAtOffset(value: Float64, offset: Int) {
        var val = value
        setValueAtOffset(Float64.self, value: &val, offset: offset)
    }
    
    public func setStringAtOffset(value: String, length: Int, offset: Int) {
        let stringData = (value as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        if let data = stringData {
            let bytes = data.bytes
            var range = NSMakeRange(offset, data.length)
            if !replaceMode {
                range.length = 0
            }
            replaceBytesInRange(range, withBytes: bytes, length: data.length)
            
            let pad = length - data.length
            if pad > 0 {
                var ptr = UnsafeMutablePointer<UInt8>.alloc(1)
                ptr.initialize(0)
                replaceBytesInRange(NSMakeRange(offset + data.length, replaceMode ? pad : 0), withBytes: ptr, length: pad)
                ptr.dealloc(1)
            }
            
        }
    }
    
}

