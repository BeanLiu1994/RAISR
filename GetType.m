function pType=GetType(Pos,R)
    pType=mod(Pos(1)-1,R)*R+mod(Pos(2)-1,R)+1;
end