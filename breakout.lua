
function _init()
    pos_x = 8
    pos_y = 8
    player = 1
end

function _update()
    get_input()
    move_player()
end

function get_input()
    -- Button layout --
    -- 0 = left
    -- 1 = right
    -- 2 = up 
    -- 3 = down
    -- 4 = C (O button)
    -- 5 = x (X button)
    new_x = 0
    new_y = 0
    if btnp(1) then 
        new_x  = 1 
        player = 1 
    end
    if btnp(0) then 
        new_x  = -1 
        player = 2 
    end
    if btnp(2) then new_y = -1 end
    if btnp(3) then new_y =  1 end
end

function move_player()
    pos_x += new_x
    pos_y += new_y
end

function _draw()
    cls(0)
    map()
    spr(player, pos_x*8, pos_y*8)
end
