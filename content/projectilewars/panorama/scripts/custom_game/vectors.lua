require("typescript_lualib")
Vector = Vector or {}
Vector.__index = Vector
function Vector.new(construct, ...)
    local instance = setmetatable({}, Vector)
    if construct and Vector.constructor then Vector.constructor(instance, ...) end
    return instance
end
function Vector.constructor(self,x,y,z)
    self.x=(x or 0)
    self.y=(y or 0)
    self.z=(z or 0)
end
function Vector.toString(self)
    return "Vector("..self.x..", "..self.y..", "..self.z..")"
end
function Vector.Length(self)
    return math.sqrt(((self.x*self.x)+(self.y*self.y))+(self.z*self.z))
end
function Vector.LengthSquared(self)
    return ((self.x*self.x)+(self.y*self.y))+(self.z*self.z)
end
function Vector.DistanceTo(self,v2)
    return math.sqrt((((v2.x-self.x)*(v2.x-self.x))+((v2.y-self.y)*(v2.y-self.y)))+((v2.z-self.z)*(v2.z-self.z)))
end
function Vector.Substract(self,v2)
    return Vector.new(true,self.x-v2.x,self.y-v2.y,self.z-v2.z)
end
function Vector.Add(self,v2)
    return Vector.new(true,self.x+v2.x,self.y+v2.y,self.z+v2.z)
end
function Vector.Scale(self,s)
    return Vector.new(true,self.x*s,self.y*s,self.z*s)
end
function Vector.ScaleTo(self,s)
    local length = Vector.Length(self)

    if length==0 then
        return Vector.new(true,0,0,0)
    else
        return Vector.Scale(self,s/length)
    end
end
function Vector.Normalize(self)
    local length = Vector.Length(self)

    return Vector.new(true,self.x/length,self.y/length,self.z/length)
end
function Vector.Dot(self,v2)
    return ((self.x*v2.x)+(self.y*v2.y))+(self.z*v2.z)
end
function Vector.Cross(self,v2)
    return Vector.new(true,(self.y*v2.z)-(self.z*v2.y),(self.z*v2.x)-(self.x*v2.z),(self.x*v2.y)-(self.y*v2.x))
end
function ArrayToVector(array)
    if #array==2 then
        return Vector.new(true,array[0+1],array[1+1],0)
    else
        if #array==3 then
            return Vector.new(true,array[0+1],array[1+1],array[2+1])
        else
            return Vector.new(true,0,0,0)
        end
    end
end
function VectorToArray(v)
    local a = v.x or 0

    local b = v.y or 0

    local c = v.z or 0

    return {a,b,c}
end
