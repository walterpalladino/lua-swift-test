//
//  ViewController.swift
//  LUA Integration Test
//
//  Created by Walter Palladino on 3/8/17.
//  Copyright © 2017 Walter Palladino. All rights reserved.
//

import Cocoa

class LuaViewController: NSViewController {
    
    
    @IBOutlet var clear : NSButton!
    @IBOutlet var run : NSButton!
    @IBOutlet var program : NSTextView!
    @IBOutlet var output : NSTextField!
    
    var lua_state: OpaquePointer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        initListeners ()
 
    }
    
    
    private func initListeners () {
        clear.action = #selector(LuaViewController.clearProgram)
        run.action = #selector(LuaViewController.runProgram)
        
        program.isEditable = true
        output.stringValue = ""
    }
    
    public func clearProgram (_ sender: AnyObject) {
        program.textStorage?.mutableString.setString("")
    }
    
    public func runProgram (_ sender: AnyObject) {
        
        
        output.stringValue = ""
        
        lua_state = luaL_newstate()
        luaL_openlibs(lua_state)
        
        //luaL_dofile(L, "helloworld.lua");
        //luaL_loadfile(L, "helloworld.lua")
        //lua_pcall(L, 0, LUA_MULTRET, 0);
        
        // initialize Lua and our load our lua file
        lua_state = luaL_newstate(); // create a new state structure for the interpreter
        luaL_openlibs(lua_state); // load all the basic libraries into the interpreter
        
        lua_settop(lua_state, 0)
        
        var status : Int32!
        
        let programAsString : String = (program.textStorage?.string)! //.replacingOccurrences(of: "\"", with: "'")
        //Swift.print((programAsString ?? "No program")!)
        //err = luaL_loadstring(L, "print(\"Hello, world.\")")
        status = luaL_loadstring(lua_state, programAsString)
        
        if (status == LUA_OK) {
            Swift.print("Program loaded OK")
            status = lua_pcallk(lua_state, 0, LUA_MULTRET, 0, 0, nil)
            
            while(lua_gettop(lua_state) != 0) {
                
                switch(lua_type(lua_state, lua_gettop(lua_state))) {
                case LUA_TNUMBER:
                    Swift.print("LUA_TNUMBER")
//                    Swift.print( lua_tonumber(lua_state, lua_gettop(lua_state)) )
                    Swift.print( lua_tonumberx(lua_state,lua_gettop(lua_state),nil) )
//                    std::cout << "script returned the number: " << lua_tonumber(lua_state, lua_gettop(lua_state)) << std::endl;
                    break;
                    
                case LUA_TTABLE:
                    Swift.print("LUA_TTABLE")
                    
                    var len: Int = lua_rawlen (lua_state, -1)
                    Swift.print("Table len: \(len)")
                    luaTableIterate(lua_state: lua_state, index: -1)
                   // {
  //                      std::cout  << "script returned a table" << std::endl;
                        
    //                    size_t len = lua_rawlen (lua_state, -1);
      //                  std::cout  << "table size: " << len << " elements." << std::endl;
        //                iterate_and_print(lua_state, -1);
                    //}
                    break
                    
                case LUA_TSTRING:
                    Swift.print("LUA_TSTRING")
                    /*
                    var len: Int = 0
                    let str = lua_tolstring(lua_state, -1, &len)
                    let data = Data(bytes: str!, count: Int(len))
                    let value = String(data: data, encoding: String.Encoding.utf8)
                    */
                    let value : String = getLuaString(lua_state: lua_state, index: -1)
                    
                    Swift.print( value ?? "No value recovered" )
          //          std::cout  << "script returned the string: "
            //        << lua_tostring(lua_state, lua_gettop(lua_state)) << std::endl;
                    break;
                case LUA_TBOOLEAN:
                    Swift.print("LUA_TBOOLEAN")
                    Swift.print( lua_toboolean(lua_state, lua_gettop(lua_state)) )
              //      std::cout  << "script returned the boolean: "
               //     << lua_toboolean(lua_state, lua_gettop(lua_state)) << std::endl;
                    break
                default:
                    Swift.print("Anything else")
                    break
                //    std::cout  << "script returned an unknown-type value" << std::endl;
                }

                
                
                //lua_pop(lua_state, 1)
                lua_settop(lua_state, -2)
            }
            
        } else {
            Swift.print("Error loading program. Status Code:\(status)")

        }
        
        /*
        if (0 != err) {
            //            luaL_error(L, "cannot compile lua file: %s",
            //                       lua_tostring(L, -1));
            //            return;
        } else {
            
            //            err = lua_pcall(L, 0, 0, 0);
            //#define lua_pcall(L,n,r,f)	lua_pcallk(L, (n), (r), (f), 0, NULL)
            err = lua_pcallk(L, 0, LUA_MULTRET, 0, 0, nil)
            //            if (0 != err) {
            //                luaL_error(L, "cannot run lua file: %s",
            //                           lua_tostring(L, -1));
            //                return;
            //            }
        }
        */
        
        
        lua_close(lua_state)
    }
    
    private func luaTableIterate (lua_state : OpaquePointer!, index : Int32) {
        
        Swift.print("iterate and print table content >>")
        
        // Push another reference to the table on top of the stack (so we know
        // where it is, and this function can work for negative, positive and
        // pseudo indices
        lua_pushvalue(lua_state, index);
        
        // stack now contains: -1 => table
        lua_pushnil(lua_state);
        // stack now contains: -1 => nil; -2 => table
        
        while (lua_next(lua_state, -2) != 0) {
            
            // stack now contains: -1 => value; -2 => key; -3 => table
            // copy the key so that lua_tostring does not modify the original
            lua_pushvalue(lua_state, -2);
            
            // stack now contains: -1 => key; -2 => value; -3 => key; -4 => table
            var key : String = getLuaString(lua_state: lua_state, index: -1)
            var value : String = getLuaString(lua_state: lua_state, index: -2)
            
            Swift.print("key :\(key)")
            Swift.print("value :\(value)")
            
            if (lua_type(lua_state, -2) == LUA_TSTRING) {
                Swift.print("Key [\(key)] - Value [\(value)]")
                //std::cout << lua_tostring(lua_state, -1) << "=" << lua_tostring(lua_state, -2) << std::endl;
            } else if (lua_type(lua_state, -2) == LUA_TNUMBER) {
                Swift.print("Key [\(key)] - Value [\(value)]")
                //std::cout << lua_tostring(lua_state, -1) << "=" << lua_tonumber(lua_state, -2) << std::endl;
            } else if (lua_type(lua_state, -2) == LUA_TTABLE) {
                //std::cout << lua_tostring(lua_state, -1) << "=" << "found a nested table here" << std::endl;
                
                luaTableIterate(lua_state: lua_state, index: -2)
            } else {
                Swift.print("Key [\(key)] - Value [\(value)]")
                //std::cout << lua_tostring(lua_state, -1) << "=" << "something else here" << std::endl;
            }
            
            
            // pop value + copy of key, leaving original key
            //lua_pop(L, 2);
            lua_settop(lua_state, -3)
            // stack now contains: -1 => key; -2 => table
        }
        
        
        // stack now contains: -1 => table (when lua_next returns 0 it pops the key
        // but does not push anything.)
        // Pop table
        //lua_pop(lua_state, 1);
        lua_settop(lua_state, -2)
        // Stack is now the same as it was on entry to this function
    }
    /*
 
     void iterate_and_print(lua_State *L, int index)
     {
     std::cout << "iterate and print table content >>" << std::endl;
     // Push another reference to the table on top of the stack (so we know
     // where it is, and this function can work for negative, positive and
     // pseudo indices
     lua_pushvalue(L, index);
     // stack now contains: -1 => table
     lua_pushnil(L);
     // stack now contains: -1 => nil; -2 => table
     while (lua_next(L, -2))
     {
     // stack now contains: -1 => value; -2 => key; -3 => table
     // copy the key so that lua_tostring does not modify the original
     lua_pushvalue(L, -2);
     // stack now contains: -1 => key; -2 => value; -3 => key; -4 => table
     const char *key = lua_tostring(L, -1);
     const char *value = lua_tostring(L, -2);
     
     if (lua_isstring(L, -2)) {
     std::cout << lua_tostring(L, -1) << "=" << lua_tostring(L, -2) << std::endl;
     } else if (lua_isnumber(L, -2)) {
     std::cout << lua_tostring(L, -1) << "=" << lua_tonumber(L, -2) << std::endl;
     } else if (lua_istable(L, -2)) {
     std::cout << lua_tostring(L, -1) << "=" << "found a nested table here" << std::endl;
     
     iterate_and_print(L, -2);
     } else {
     std::cout << lua_tostring(L, -1) << "=" << "something else here" << std::endl;
     }
     
     //        printf("%s => %s\n", key, value);
     // pop value + copy of key, leaving original key
     lua_pop(L, 2);
     // stack now contains: -1 => key; -2 => table
     }
     // stack now contains: -1 => table (when lua_next returns 0 it pops the key
     // but does not push anything.)
     // Pop table
     lua_pop(L, 1);
     // Stack is now the same as it was on entry to this function
     }
 */
    
    
    private func getLuaString (lua_state : OpaquePointer!, index : Int32) -> String! {
        
        var len: Int = 0
        let str = lua_tolstring(lua_state, index, &len)
        let data = Data(bytes: str!, count: Int(len))
        let value = String(data: data, encoding: String.Encoding.utf8)
        
        return value
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}
