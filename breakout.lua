
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
        sprite_position    = {x = tile_size*(grid_size*0.5)-4, y = tile_size * (grid_size - 1)},
        width              = 8,
        height             = 2,
    }
    paddle_top = {
        sprite_position = {x = tile_size*(grid_size*0.5)-4, y = 0 },
        width           = 8,
        height          = 2,
        y_offset        = 6,
    }
    paddle_left_bot = {
        sprite_position = {x = 0, y = 90},--tile_size*(grid_size*0.75)},
        width    = 2,
        height   = 8, 
        x_offset = 6,
    }
    paddle_right_bot = {
        sprite_position = {x = tile_size * (grid_size - 1), y = 90},--tile_size*(grid_size*0.75)},
        width           = 2,
        height          = 8,
    }
    paddle_left_top = {
        sprite_position = {x = 0, y = 30},--tile_size*(grid_size*0.25)-8},
        width    = 2,
        height   = 8, 
        x_offset = 6,
    }
    paddle_right_top = {
        sprite_position = {x = tile_size * (grid_size - 1), y = 30},--tile_size*(grid_size*0.25)-8},
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
        real_position = {min_x = ball_sprite_pos.x + x_offset, 
                         max_x = ball_sprite_pos.x + x_offset + 1,
                         min_y = ball_sprite_pos.y + y_offset,
                         max_y = ball_sprite_pos.y + y_offset + 1},
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
        local new_dir_x = rnd(2) - 1
        local direction_magnitude = sqrt(new_dir_x*new_dir_x + ball.direction.y * ball.direction.y)
        ball.direction.x = new_dir_x / direction_magnitude
        ball.direction.y /= direction_magnitude 
    end
end

function move_ball() 
    if ball.is_launched then
        ball.sprite_position.x += ball.direction.x * ball.speed
        ball.sprite_position.y += ball.direction.y * ball.speed

        ball.real_position.min_x = ball.sprite_position.x + ball.x_offset
        ball.real_position.max_x = ball.real_position.min_x + 1
        ball.real_position.min_y = ball.sprite_position.y + ball.y_offset
        ball.real_position.max_y = ball.real_position.min_y + 1

        --[[
        if ball.real_position.min_y <= 0 or ball.real_position.max_y >= 128 then 
           ball.direction.y = -ball.direction.y
        end
        if ball.real_position.min_x <= 0 or ball.real_position.max_x >= 128 then 
            ball.direction.x = -ball.direction.x
        end
        --]]
        if ball.real_position.max_y < 0 then
            ball.sprite_position.y = 128 - ball.y_offset
        elseif ball.real_position.min_y > 128 then
            ball.sprite_position.y = 0 - (ball.y_offset)
        end
        if ball.real_position.max_x < 0 then
            ball.sprite_position.x = 128 - ball.x_offset
        elseif ball.real_position.min_x > 128 then
            ball.sprite_position.x = 0 - (ball.x_offset)
        end

        for block in all(active_blocks) do
            if block.alive then
                if ball.real_position.min_y <= block.max_y and
                   ball.real_position.max_y >= block.min_y and
                   ball.real_position.max_x >= block.min_x and 
                   ball.real_position.min_x <= block.max_x then
                   local overlapped_x = min(ball.real_position.max_x - block.min_x, 
                                            block.max_x - ball.real_position.min_x)
                   local overlapped_y = min(ball.real_position.max_y - block.min_y, 
                                            block.max_y - ball.real_position.min_y)
                   if overlapped_x < overlapped_y then
                            ball.direction.x = -ball.direction.x
                   else
                            ball.direction.y = -ball.direction.y
                   end
                        block.alive = false
                   break
                end
            end
        end

        --[[
        ball.sprite_position.y = mid(0 - ball.y_offset, ball.sprite_position.y, 128 + ball.y_offset)
        ball.sprite_position.x = mid(0 - ball.x_offset, ball.sprite_position.x, 128 + ball.x_offset)
        --]]
    end
end


function collide_with_paddles()
    if ball.is_launched then
        -- TODO: get AABB collision working with paddles 
        local ball_pos_min_y  = ball.real_position.min_y 
        local ball_pos_min_x  = ball.real_position.min_x 
        local ball_pos_max_y  = ball.real_position.max_y 
        local ball_pos_max_x  = ball.real_position.max_x 
        local new_direction_x = ball.direction.x
        local new_direction_y = ball.direction.y
        local has_collided    = false

        if ball_pos_max_y >= paddle_bot.sprite_position.y and
           ball_pos_min_y <= (paddle_bot.sprite_position.y + paddle_bot.height) and 
           ball_pos_max_x >= paddle_bot.sprite_position.x and 
           ball_pos_min_x <= (paddle_bot.sprite_position.x + paddle_bot.width) then
               
               local half_size         = paddle_bot.width * 0.5
               local distance_from_mid = ball_pos_min_x - (paddle_bot.sprite_position.x + half_size)
               new_direction_x         = (distance_from_mid / half_size)
               new_direction_y         = -new_direction_y
               has_collided            = true

               ball.real_position.max_y = paddle_bot.sprite_position.y - 1
        end

        if ball_pos_max_y >= (paddle_top.sprite_position.y + paddle_top.y_offset) and
           ball_pos_min_y <= (paddle_top.sprite_position.y + paddle_top.y_offset + paddle_top.height) and 
           ball_pos_max_x >= paddle_top.sprite_position.x and 
           ball_pos_min_x <= (paddle_top.sprite_position.x + paddle_top.width) then

               local half_size         = paddle_top.width * 0.5
               local distance_from_mid = ball_pos_min_x - (paddle_top.sprite_position.x + half_size)
               new_direction_x         = (distance_from_mid / half_size)
               new_direction_y         = -new_direction_y
               has_collided            = true

               ball.real_position.min_y = paddle_top.sprite_position.y + paddle_top.height + 
                                          paddle_top.y_offset + 1
        end

        if ball_pos_max_y >= paddle_right_bot.sprite_position.y and
           ball_pos_min_y <= (paddle_right_bot.sprite_position.y + paddle_right_bot.height) and 
           ball_pos_max_x >= paddle_right_bot.sprite_position.x and 
           ball_pos_min_x <= (paddle_right_bot.sprite_position.x + paddle_right_bot.width) then

               local half_size         = paddle_right_bot.height * 0.5
               local distance_from_mid = ball_pos_min_y - (paddle_right_bot.sprite_position.y + half_size)
               local dir_y_amount      = distance_from_mid / half_size
               new_direction_y         = dir_y_amount
               new_direction_x         = -new_direction_x
               has_collided            = true

               ball.real_position.max_x = paddle_right_bot.sprite_position.x - 1
        end

        if ball_pos_max_y >= paddle_left_bot.sprite_position.y and 
           ball_pos_min_y <= (paddle_left_bot.sprite_position.y + paddle_left_bot.height) and 
           ball_pos_max_x >= (paddle_left_bot.sprite_position.x + paddle_left_bot.x_offset) and 
           ball_pos_min_x <= (paddle_left_bot.sprite_position.x + paddle_left_bot.x_offset + paddle_left_bot.width) then

               local half_size         = paddle_left_bot.height * 0.5
               local distance_from_mid = ball_pos_min_y - (paddle_left_bot.sprite_position.y + half_size)
               local dir_y_amount      = distance_from_mid / half_size
               new_direction_y         = dir_y_amount
               new_direction_x         = -new_direction_x
               has_collided            = true

               ball.real_position.min_x = paddle_left_bot.sprite_position.x + paddle_left_bot.width + 
                                          paddle_left_bot.x_offset + 1
        end

        if ball_pos_max_y >= paddle_right_top.sprite_position.y and
           ball_pos_min_y <= (paddle_right_top.sprite_position.y + paddle_right_top.height) and 
           ball_pos_max_x >= paddle_right_top.sprite_position.x and 
           ball_pos_min_x <= (paddle_right_top.sprite_position.x + paddle_right_top.width) then

               local half_size         = paddle_right_top.height * 0.5
               local distance_from_mid = ball_pos_min_y - (paddle_right_top.sprite_position.y + half_size)
               local dir_y_amount      = distance_from_mid / half_size
               new_direction_y         = dir_y_amount
               new_direction_x         = -new_direction_x
               has_collided            = true

               ball.real_position.max_x = paddle_right_top.sprite_position.x - 1
        end

        if ball_pos_max_y >= paddle_left_top.sprite_position.y and 
           ball_pos_min_y <= (paddle_left_top.sprite_position.y + paddle_left_top.height) and 
           ball_pos_max_x >= (paddle_left_top.sprite_position.x + paddle_left_top.x_offset) and 
           ball_pos_min_x <= (paddle_left_top.sprite_position.x + paddle_left_top.x_offset + paddle_left_top.width) then

               local half_size         = paddle_left_top.height * 0.5
               local distance_from_mid = ball_pos_min_y - (paddle_left_top.sprite_position.y + half_size)
               local dir_y_amount      = distance_from_mid / half_size
               new_direction_y         = dir_y_amount
               new_direction_x         = -new_direction_x
               has_collided            = true

               ball.real_position.min_x = paddle_left_top.sprite_position.x + paddle_left_top.width + 
                                          paddle_left_top.x_offset + 1
        end

        if has_collided then
            local ball_direction_magnitude = sqrt(new_direction_x*new_direction_x + 
                                                  new_direction_y*new_direction_y)
            ball.direction.x = new_direction_x / ball_direction_magnitude
            ball.direction.y = new_direction_y / ball_direction_magnitude
        end
    end
end

function move_paddles()
    local min_pos      = 8
    local half_pos = tile_size * (grid_size*0.5)
    local max_pos      = tile_size * (grid_size - 2)
    local velocity     = 3.5

    paddle_bot.sprite_position.x       += (new_x * velocity)
    paddle_top.sprite_position.x       += (new_x * velocity)
    paddle_left_bot.sprite_position.y  -= (new_y * velocity*0.5)
    paddle_right_bot.sprite_position.y += (new_y * velocity*0.5)
    paddle_left_top.sprite_position.y  += (new_y * velocity*0.5)
    paddle_right_top.sprite_position.y -= (new_y * velocity*0.5)
    paddle_bot.sprite_position.x        = mid(min_pos, paddle_bot.sprite_position.x, max_pos)
    paddle_top.sprite_position.x        = mid(min_pos, paddle_top.sprite_position.x, max_pos)
    paddle_left_bot.sprite_position.y       = mid(half_pos, paddle_left_bot.sprite_position.y, max_pos)
    paddle_right_bot.sprite_position.y      = mid(half_pos, paddle_right_bot.sprite_position.y, max_pos)
    paddle_left_top.sprite_position.y       = mid(min_pos, paddle_left_top.sprite_position.y, half_pos-8)
    paddle_right_top.sprite_position.y      = mid(min_pos, paddle_right_top.sprite_position.y, half_pos-8)
end

function _draw()
    cls(0)
    --map(0)
    spr(8, paddle_bot.sprite_position.x,    paddle_bot.sprite_position.y)
    spr(9, paddle_top.sprite_position.x,    paddle_top.sprite_position.y)
    spr(10, paddle_left_bot.sprite_position.x,  paddle_left_bot.sprite_position.y)
    spr(11, paddle_right_bot.sprite_position.x, paddle_right_bot.sprite_position.y)
    spr(10, paddle_left_top.sprite_position.x,  paddle_left_top.sprite_position.y)
    spr(11, paddle_right_top.sprite_position.x, paddle_right_top.sprite_position.y)
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
    pset(ball.real_position.min_x, ball.real_position.min_y, 3)
    pset(ball.real_position.max_x, ball.real_position.max_y, 3)
end
