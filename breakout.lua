
function load_level(data)
    local start_x      = 36
    local start_y      = 48
    local block_width  = 8
    local block_height = 4

    for row = 1, #data do 
        for col = 1, #data[row] do 
            local block_type = data[row][col]

            if block_type > 0 then 
                local new_block = {
                    min_x = start_x + (col - 1) * block_width,
                    max_x = (start_x + (col - 1) * block_width) + block_width,
                    min_y = start_y + (row - 1) * block_height, 
                    max_y = (start_y + (row - 1) * block_height) + block_height, 
                    type = block_type, 
                    alive = true
                }
                add(active_blocks, new_block)
            end
        end
    end
end

function _init()
    tile_size      = 8
    grid_size      = 16
    pos_x          = 8
    pos_y          = 8

    paddle_bot = {
        sprite_position    = {x = tile_size*(grid_size*0.5), y = tile_size * (grid_size - 1)},
        width              = 8,
        height             = 2,
    }
    paddle_top = {
        sprite_position = {x = (tile_size*((grid_size*0.5)-1)), y = 0 },
        width           = 8,
        height          = 2,
        y_offset        = 6,
    }
    paddle_left = {
        sprite_position = {x = 0, y = tile_size*(grid_size*0.5)},
        width    = 2,
        height   = 8, 
        x_offset = 6,
    }
    paddle_right = {
        sprite_position = {x = tile_size * (grid_size - 1), y = (tile_size*((grid_size*0.5)-1))},
        width           = 2,
        height          = 8,
    }

    local x_offset = 3
    local y_offset = 6
    local ball_sprite_pos = {x = paddle_bot.sprite_position.x, y = paddle_bot.sprite_position.y - 8}
    local ball_speed = 2.0
    ball = {
        sprite_position = {x = ball_sprite_pos.x, y = ball_sprite_pos.y},
        y_offset = y_offset,
        x_offset = x_offset,
        real_position = {x = ball_sprite_pos.x + x_offset, y = ball_sprite_pos.y + y_offset},
        is_launched = false,
        speed = ball_speed,
        direction = {x = 0, y = -ball_speed},
    }
    
    sprite_pos = {x = 8*8, y = 8*8}
    --srand(4)

    active_blocks = {}

    level_data = {
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {0, 2, 0, 2, 0, 2, 0},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1}
    }

    load_level(level_data)
end

function _update()
    get_button_held()
    move_paddles()
    move_ball()
    collide_with_paddles()
end


function get_button_held()
    -- Button layout --
    -- 0 = left
    -- 1 = right
    -- 2 = up 
    -- 3 = down
    -- 4 = C (O button)
    -- 5 = x (X button)
    new_x = 0
    new_y = 0

    if btn(1) then 
        new_x  = 1 
        new_y  = 1 
    end
    if btn(0) then 
        new_x  = -1 
        new_y  = -1
    end
    if btn(2) then 
        new_y = -1 
    end
    if btn(3) then 
        new_y =  1 
    end
    if btnp(4) or btnp(5) then 
        ball.is_launched = true 
        ball.direction.x = rnd(2) - 1
    end
end

function move_ball() 
    if ball.is_launched then
        ball.sprite_position.x += ball.direction.x
        ball.sprite_position.y += ball.direction.y

        ball.real_position.x = ball.sprite_position.x + ball.x_offset
        ball.real_position.y = ball.sprite_position.y + ball.y_offset

        if ball.real_position.y <= 0 or ball.real_position.y >= 128 then 
           ball.direction.y = -ball.direction.y
        end
        if ball.real_position.x <= 0 or ball.real_position.x >= 128 then 
            ball.direction.x = -ball.direction.x
        end

        for block in all(active_blocks) do
            if block.alive then
                if ball.real_position.y <= block.max_y and
                   ball.real_position.y >= block.min_y and
                   ball.real_position.x >= block.min_x and 
                   ball.real_position.x <= block.max_x then
                        ball.direction.y = -ball.direction.y
                        block.alive = false
                        break
                end
            end
        end

        ball.sprite_position.y = mid(0 - ball.y_offset, ball.sprite_position.y, 128 + ball.y_offset)
        ball.sprite_position.x = mid(0 - ball.x_offset, ball.sprite_position.x, 128 + ball.x_offset)
    end
end


function collide_with_paddles()
    if ball.is_launched then
        if ball.real_position.y >= paddle_bot.sprite_position.y and
           ball.real_position.y <= paddle_bot.sprite_position.y + paddle_bot.height and 
           ball.real_position.x >= paddle_bot.sprite_position.x and 
           ball.real_position.x <= paddle_bot.sprite_position.x + paddle_bot.width then
               
               local paddle_half_width = paddle_bot.width * 0.5
               local ball_distance_from_paddle_mid = ball.real_position.x - 
                                                     (paddle_bot.sprite_position.x + paddle_half_width)
               ball.direction.x = (ball_distance_from_paddle_mid / paddle_half_width) * 2.0

               ball.direction.y = -ball.direction.y
               ball.real_position.y -= paddle_bot.sprite_position.y - 1
        end

        if ball.real_position.y >= paddle_top.sprite_position.y + paddle_top.y_offset and
           ball.real_position.y <= paddle_top.sprite_position.y + paddle_top.y_offset + paddle_top.height and 
           ball.real_position.x >= paddle_top.sprite_position.x and 
           ball.real_position.x <= paddle_top.sprite_position.x + paddle_top.width then

               local paddle_half_width = paddle_top.width * 0.5
               local ball_distance_from_paddle_mid = ball.real_position.x - 
                                                     (paddle_top.sprite_position.x + paddle_half_width)
               ball.direction.x = (ball_distance_from_paddle_mid / paddle_half_width) * 2.0

               ball.direction.y = -ball.direction.y
               ball.real_position.y -= paddle_top.sprite_position.y + paddle_top.height + 
                                       paddle_top.y_offset + 1
        end

        if ball.real_position.y >= paddle_right.sprite_position.y and
           ball.real_position.y <= paddle_right.sprite_position.y + paddle_right.height and 
           ball.real_position.x >= paddle_right.sprite_position.x and 
           ball.real_position.x <= paddle_right.sprite_position.x + paddle_right.width then
               ball.direction.x = -ball.direction.x
               ball.real_position.x = paddle_right.sprite_position.x - 1
        end

        if ball.real_position.y >= paddle_left.sprite_position.y and 
           ball.real_position.y <= paddle_left.sprite_position.y + paddle_left.height and 
           ball.real_position.x >= paddle_left.sprite_position.x + paddle_left.x_offset and 
           ball.real_position.x <= paddle_left.sprite_position.x + paddle_left.x_offset + paddle_left.width then
               ball.direction.x = -ball.direction.x
               ball.real_position.x = paddle_left.sprite_position.x + paddle_left.width + 
                                      paddle_left.x_offset + 1
        end
    end
end

function move_paddles()
    local min_pos  = 0
    local max_pos  = tile_size * (grid_size - 1)
    local velocity = 2

    paddle_bot.sprite_position.x   += (new_x * velocity)
    paddle_top.sprite_position.x   -= (new_x * velocity)
    paddle_left.sprite_position.y  += (new_y * velocity)
    paddle_right.sprite_position.y -= (new_y * velocity)
    paddle_bot.sprite_position.x    = mid(min_pos, paddle_bot.sprite_position.x, max_pos)
    paddle_top.sprite_position.x    = mid(min_pos, paddle_top.sprite_position.x, max_pos)
    paddle_left.sprite_position.y   = mid(min_pos, paddle_left.sprite_position.y, max_pos)
    paddle_right.sprite_position.y  = mid(min_pos, paddle_right.sprite_position.y, max_pos)
end

function _draw()
    cls(0)
    --map(0)
    spr(8, paddle_bot.sprite_position.x,    paddle_bot.sprite_position.y)
    spr(9, paddle_top.sprite_position.x,    paddle_top.sprite_position.y)
    spr(10, paddle_left.sprite_position.x,  paddle_left.sprite_position.y)
    spr(11, paddle_right.sprite_position.x, paddle_right.sprite_position.y)
    --[[
    spr(13, pos_x*8, pos_y*8)
    spr(13, pos_x*8+8, pos_y*8)
    spr(13, pos_x*8, ((pos_y*8)-4))
    spr(13, (pos_x*8)+8, ((pos_y*8)-4))
    ]]
    for block in all(active_blocks) do
        if block.alive then
            local sprite_id = 0 
            if block.type == 1 then sprite_id = 13 end
            if block.type == 2 then sprite_id = 15 end

            spr(sprite_id, block.min_x, block.min_y)
        end
    end
    spr(14, ball.sprite_position.x, ball.sprite_position.y)
    spr(14, sprite_pos.x, sprite_pos.y)
    --pset(paddle_bot_x+4, paddle_bot_y-8, 7)
    pset(127,127,12)
    pset(0,127,12)
    pset(ball.sprite_position.x, ball.sprite_position.y, 12)
    pset(ball.real_position.x, ball.real_position.y, 3)
end
