-------------------------------------------------
-- Class to maintain all utility functions.
--
-- @module Util
-- @author Julian Meyer
-- @copyright Julian Meyer 2016
-------------------------------------------------

Util = {}

-------------------------------------------------
-- Deep copies a table
-- @tparam tab t Table to clone.
-- @treturn tab Cloned table.
-------------------------------------------------
function Util.clone (t) -- deep-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = Util.clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

-------------------------------------------------
-- Prints complex data structures like tables.
-- @tparam tab t Table to print.
-------------------------------------------------
function Util.print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

-------------------------------------------------
-- Finds the distance between two points
-- @tparam int x1 X-Coordinate of first point
-- @tparam int y1 Y-Coordinate of first point
-- @tparam int x2 X-Coordinate of second point
-- @tparam int y2 Y-Coordinate of second point
-------------------------------------------------
function Util.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

-------------------------------------------------
-- Checks if a table contains a value.
-- @tparam tab tab Table to check.
-- @param val Value to check.
-- @treturn bool Whether tab contains val.
-------------------------------------------------
function Util.has_value (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

-------------------------------------------------
-- Removes a value from a table
-- @tparam tab tab Table to remove from.
-- @param val Value to remove.
-- @treturn bool false if value not found.
-------------------------------------------------
function Util.remove_value (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            table.remove(tab, index)
        end
    end

    return false
end

-------------------------------------------------
-- Interpolates between v0 and v1 by t
-- @tparam number v0 First value to interpolate between.
-- @tparam number v1 Second value to interpolate between.
-- @tparam number t Percentage to interpolate between.
-- @treturn number Interpolated value.
-------------------------------------------------
function Util.lerp(v0, v1, t)
  return (1-t) * v0 + t * v1
end

return Util
