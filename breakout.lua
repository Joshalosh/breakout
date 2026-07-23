
function load_level(data, start_x, start_y)
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
        velocity           = 0,
    }
    paddle_top = {
        sprite_position = {x = tile_size*(grid_size*0.5)-4, y = 0 },
        width           = 8,
        height          = 2,
        y_offset        = 6,
        velocity        = 0,
    }
    paddle_left_bot = {
        sprite_position = {x = 0, y = 90},--tile_size*(grid_size*0.75)},
        width    = 2,
        height   = 8, 
        x_offset = 6,
        velocity = 0,
    }
    paddle_right_bot = {
        sprite_position = {x = tile_size * (grid_size - 1), y = 90},--tile_size*(grid_size*0.75)},
        width           = 2,
        height          = 8,
        velocity        = 0,
    }
    paddle_left_top = {
        sprite_position = {x = 0, y = 30},--tile_size*(grid_size*0.25)-8},
        width    = 2,
        height   = 8, 
        x_offset = 6,
        velocity = 0,
    }
    paddle_right_top = {
        sprite_position = {x = tile_size * (grid_size - 1), y = 30},--tile_size*(grid_size*0.25)-8},
        width           = 2,
        height          = 8,
        velocity        = 0,
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
        sprite = 16,
        teleported = false,
    }
    
    sprite_pos = {x = 8*8, y = 8*8}
    --srand(4)

    active_blocks = {}

    level_data_1 = {
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
        {0, 2, 0, 2, 0, 2, 0},
        {1, 1, 1, 1, 1, 1, 1},
        {1, 1, 1, 1, 1, 1, 1},
    }

    level_data_2 = {
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2},
        {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2},
        {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    }

    start_x = 36
    start_y = 48
    load_level(level_data_1, start_x, start_y)
    block_count = #active_blocks
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
    --[[
    if btn(2) then 
        new_y = -1 
    end
    if btn(3) then 
        new_y =  1 
    end
    --]]
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
        
        local ball_real_mid = {x = ball.real_position.min_x + 0.5, y = ball.real_position.min_y + 0.5}

        -- This commented out section is needed if I want to have the ball rebound off the walls
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
            ball.teleported = false
        elseif ball.real_position.min_y > 128 then
            ball.sprite_position.y = 0 - (ball.y_offset)
            ball.teleported = false
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
                   --
                   -- We have a collision! 
                   -- Look at where the ball was on the PREVIOUS frame:
                   local prev_min_x = ball.real_position.min_x - (ball.direction.x * ball.speed)
                   local prev_max_x = ball.real_position.max_x - (ball.direction.x * ball.speed)
                   local prev_min_y = ball.real_position.min_y - (ball.direction.y * ball.speed)
                   local prev_max_y = ball.real_position.max_y - (ball.direction.y * ball.speed)
                    
                   local hit_vertical = false
                   local hit_horizontal = false

                   -- If it was outside the block vertically last frame, it hit the top/bottom
                   if prev_max_y <= block.min_y or prev_min_y >= block.max_y then
                        ball.direction.y = -ball.direction.y
                        hit_vertical = true
                   end
                    
                   -- If it was outside the block horizontally last frame, it hit the left/right
                   if prev_max_x <= block.min_x or prev_min_x >= block.max_x then
                        ball.direction.x = -ball.direction.x
                        hit_horizontal = true
                   end
                    
                   -- Failsafe: if a block spawned on top of the ball, just force a bounce
                   if not hit_vertical and not hit_horizontal then
                        ball.direction.y = -ball.direction.y
                   end

                   del(active_blocks, block)
                   --block.alive = false
                   block_count -= 1
                   break
                end
            end
        end

        --[[
        -- I need to check this within a band rather than just 
        -- a straight up less than greater than check.
        if ball.sprite == 16 then 
            if ball_real_mid.y < (tile_size*grid_size)/3 or 
               ball_real_mid.y > (tile_size*grid_size) - ((tile_size*grid_size) / 3) then
               if ball.teleported == false then
                   ball.sprite_position.x = (tile_size*grid_size) - ball.sprite_position.x
                   ball.teleported = true
               end
           end
        end
        --]]

        -- This clamp is needed if I want the ball to rebound off the walls
        --[[
        ball.sprite_position.y = mid(0 - ball.y_offset, ball.sprite_position.y, 128 + ball.y_offset)
        ball.sprite_position.x = mid(0 - ball.x_offset, ball.sprite_position.x, 128 + ball.x_offset)
        --]]
    end
end

function next_level()
    load_level(level_data_2, 12, 30)
    block_count = #active_blocks
    ball.sprite = 16
end

function print_dialogue()
    if block_count <= 0 then
        next_level()
        return
    elseif block_count < 2 then
        print("they're all... gone", 12)
    elseif block_count < 3 then
        print('rethink this, we beg you', 12)
    elseif block_count < 4 then
        print('please, dont destroy us', 12)
    end
end

function collide_with_paddles()
    if not ball.is_launched then return end

    local ball_pos_min_y  = ball.real_position.min_y 
    local ball_pos_min_x  = ball.real_position.min_x 
    local ball_pos_max_y  = ball.real_position.max_y 
    local ball_pos_max_x  = ball.real_position.max_x 
    
    local ball_center_x   = ball_pos_min_x + 0.5
    local ball_center_y   = ball_pos_min_y + 0.5
    
    local new_direction_x = ball.direction.x
    local new_direction_y = ball.direction.y
    local has_collided    = false

    -- =====================================
    -- BOTTOM PADDLE (Horizontal)
    -- =====================================
    local p_bot_min_y = paddle_bot.sprite_position.y
    local p_bot_max_y = p_bot_min_y + paddle_bot.height
    local p_bot_min_x = paddle_bot.sprite_position.x
    local p_bot_max_x = p_bot_min_x + paddle_bot.width

    if not has_collided and 
       ball_pos_max_y >= p_bot_min_y and ball_pos_min_y <= p_bot_max_y and 
       ball_pos_max_x >= p_bot_min_x and ball_pos_min_x <= p_bot_max_x then
           
           local half_size = paddle_bot.width * 0.5
           new_direction_x = (ball_center_x - (p_bot_min_x + half_size)) / half_size
           
           -- Check front/back overlap
           local prev_ball_pos_min_y = ball_pos_min_y - (ball.direction.y * ball.speed) 
           local prev_ball_pos_max_y = ball_pos_max_y - (ball.direction.y * ball.speed)
           local overlap_top = prev_ball_pos_max_y - p_bot_min_y
           local overlap_bottom = p_bot_max_y - prev_ball_pos_min_y
           
           if overlap_top < overlap_bottom then
               new_direction_y = -1.0 -- Hit top face, bounce up
               ball.sprite_position.y = p_bot_min_y - ball.y_offset - 2
           else
               new_direction_y = 1.0  -- Hit bottom face, bounce down
               ball.sprite_position.y = p_bot_max_y - ball.y_offset + 1
           end
           has_collided = true
    end

    -- =====================================
    -- TOP PADDLE (Horizontal)
    -- =====================================
    local p_top_min_y = paddle_top.sprite_position.y + paddle_top.y_offset
    local p_top_max_y = p_top_min_y + paddle_top.height
    local p_top_min_x = paddle_top.sprite_position.x
    local p_top_max_x = p_top_min_x + paddle_top.width

    if not has_collided and 
       ball_pos_max_y >= p_top_min_y and ball_pos_min_y <= p_top_max_y and 
       ball_pos_max_x >= p_top_min_x and ball_pos_min_x <= p_top_max_x then

           local half_size = paddle_top.width * 0.5
           new_direction_x = (ball_center_x - (p_top_min_x + half_size)) / half_size
           
           local prev_ball_pos_min_y = ball_pos_min_y - (ball.direction.y * ball.speed)
           local prev_ball_pos_max_y = ball_pos_max_y - (ball.direction.y * ball.speed)
           local overlap_top = prev_ball_pos_max_y - p_top_min_y
           local overlap_bottom = p_top_max_y - prev_ball_pos_min_y

           if overlap_bottom < overlap_top then
               new_direction_y = 1.0 -- Hit bottom face, bounce down
               ball.sprite_position.y = p_top_max_y - ball.y_offset + 1
           else
               new_direction_y = -1.0 -- Hit top face, bounce up
               ball.sprite_position.y = p_top_min_y - ball.y_offset - 2
           end
           has_collided = true
    end

    -- =====================================
    -- RIGHT BOTTOM PADDLE (Vertical)
    -- =====================================
    local prb_min_y = paddle_right_bot.sprite_position.y
    local prb_max_y = prb_min_y + paddle_right_bot.height
    local prb_min_x = paddle_right_bot.sprite_position.x
    local prb_max_x = prb_min_x + paddle_right_bot.width

    if not has_collided and 
       ball_pos_max_y >= prb_min_y and ball_pos_min_y <= prb_max_y and 
       ball_pos_max_x >= prb_min_x and ball_pos_min_x <= prb_max_x then

           local half_size = paddle_right_bot.height * 0.5
           new_direction_y = (ball_center_y - (prb_min_y + half_size)) / half_size
           
           local prev_ball_pos_min_x = ball_pos_min_x - (ball.direction.x * ball.speed)
           local prev_ball_pos_max_x = ball_pos_max_x - (ball.direction.x * ball.speed)
           local overlap_left = prev_ball_pos_max_x - prb_min_x
           local overlap_right = prb_max_x - prev_ball_pos_min_x

           if overlap_left < overlap_right then
               new_direction_x = -1.0 -- Hit left face, bounce left
               ball.sprite_position.x = prb_min_x - ball.x_offset - 2
           else
               new_direction_x = 1.0 -- Hit right face, bounce right
               ball.sprite_position.x = prb_max_x - ball.x_offset + 1
           end
           has_collided = true
    end

    -- =====================================
    -- LEFT BOTTOM PADDLE (Vertical)
    -- =====================================
    local plb_min_y = paddle_left_bot.sprite_position.y
    local plb_max_y = plb_min_y + paddle_left_bot.height
    local plb_min_x = paddle_left_bot.sprite_position.x + paddle_left_bot.x_offset
    local plb_max_x = plb_min_x + paddle_left_bot.width

    if not has_collided and 
       ball_pos_max_y >= plb_min_y and ball_pos_min_y <= plb_max_y and 
       ball_pos_max_x >= plb_min_x and ball_pos_min_x <= plb_max_x then

           local half_size = paddle_left_bot.height * 0.5
           new_direction_y = (ball_center_y - (plb_min_y + half_size)) / half_size
           
           local prev_ball_pos_min_x = ball_pos_min_x - (ball.direction.x * ball.speed)
           local prev_ball_pos_max_x = ball_pos_max_x - (ball.direction.x * ball.speed)
           local overlap_left = prev_ball_pos_max_x - plb_min_x
           local overlap_right = plb_max_x - prev_ball_pos_min_x

           if overlap_right < overlap_left then
               new_direction_x = 1.0 -- Hit right face, bounce right
               ball.sprite_position.x = plb_max_x - ball.x_offset + 1
           else
               new_direction_x = -1.0 -- Hit left face, bounce left
               ball.sprite_position.x = plb_min_x - ball.x_offset - 2
           end
           has_collided = true
    end

    -- =====================================
    -- RIGHT TOP PADDLE (Vertical)
    -- =====================================
    local prt_min_y = paddle_right_top.sprite_position.y
    local prt_max_y = prt_min_y + paddle_right_top.height
    local prt_min_x = paddle_right_top.sprite_position.x
    local prt_max_x = prt_min_x + paddle_right_top.width

    if not has_collided and 
       ball_pos_max_y >= prt_min_y and ball_pos_min_y <= prt_max_y and 
       ball_pos_max_x >= prt_min_x and ball_pos_min_x <= prt_max_x then

           local half_size = paddle_right_top.height * 0.5
           new_direction_y = (ball_center_y - (prt_min_y + half_size)) / half_size
           
           local prev_ball_pos_min_x = ball_pos_min_x - (ball.direction.x * ball.speed)
           local prev_ball_pos_max_x = ball_pos_max_x - (ball.direction.x * ball.speed)
           local overlap_left = prev_ball_pos_max_x - prt_min_x
           local overlap_right = prt_max_x - prev_ball_pos_min_x

           if overlap_left < overlap_right then
               new_direction_x = -1.0 -- Hit left face, bounce left
               ball.sprite_position.x = prt_min_x - ball.x_offset - 2
           else
               new_direction_x = 1.0 -- Hit right face, bounce right
               ball.sprite_position.x = prt_max_x - ball.x_offset + 1
           end
           has_collided = true
    end

    -- =====================================
    -- LEFT TOP PADDLE (Vertical)
    -- =====================================
    local plt_min_y = paddle_left_top.sprite_position.y
    local plt_max_y = plt_min_y + paddle_left_top.height
    local plt_min_x = paddle_left_top.sprite_position.x + paddle_left_top.x_offset
    local plt_max_x = plt_min_x + paddle_left_top.width

    if not has_collided and 
       ball_pos_max_y >= plt_min_y and ball_pos_min_y <= plt_max_y and 
       ball_pos_max_x >= plt_min_x and ball_pos_min_x <= plt_max_x then

           local half_size = paddle_left_top.height * 0.5
           new_direction_y = (ball_center_y - (plt_min_y + half_size)) / half_size
           
           local prev_ball_pos_min_x = ball_pos_min_x - (ball.direction.x * ball.speed)
           local prev_ball_pos_max_x = ball_pos_max_x - (ball.direction.x * ball.speed)
           local overlap_left = prev_ball_pos_max_x - plt_min_x
           local overlap_right = plt_max_x - prev_ball_pos_min_x

           if overlap_right < overlap_left then
               new_direction_x = 1.0 -- Hit right face, bounce right
               ball.sprite_position.x = plt_max_x - ball.x_offset + 1
           else
               new_direction_x = -1.0 -- Hit left face, bounce left
               ball.sprite_position.x = plt_min_x - ball.x_offset - 2
           end
           has_collided = true
    end

    -- Normalize
    if has_collided then
        local ball_direction_magnitude = sqrt(new_direction_x*new_direction_x + 
                                              new_direction_y*new_direction_y)
        ball.direction.x = new_direction_x / ball_direction_magnitude
        ball.direction.y = new_direction_y / ball_direction_magnitude
    end
end

function move_paddles()
    local min_pos        = 8
    local half_pos       = tile_size * (grid_size*0.5)
    local max_pos        = tile_size * (grid_size - 2)
    local speed          = 1.25
    local friction       = 0.5
    local acceleration_x = new_x * speed
    local acceleration_y = new_y * speed

    paddle_bot.velocity                += acceleration_x
    paddle_bot.sprite_position.x       += acceleration_x + paddle_bot.velocity
    paddle_bot.velocity                *= friction

    paddle_top.velocity                += acceleration_x
    paddle_top.sprite_position.x       += acceleration_x + paddle_top.velocity
    paddle_top.velocity                *= friction

    paddle_left_bot.velocity           += acceleration_y*0.25
    paddle_left_bot.sprite_position.y  -= acceleration_y + paddle_left_bot.velocity
    paddle_left_bot.velocity           *= friction

    paddle_right_bot.velocity          += acceleration_y*0.25
    paddle_right_bot.sprite_position.y += acceleration_y + paddle_right_bot.velocity
    paddle_right_bot.velocity          *= friction

    paddle_left_top.velocity           += acceleration_y*0.25
    paddle_left_top.sprite_position.y  += acceleration_y + paddle_left_top.velocity
    paddle_left_top.velocity           *= friction

    paddle_right_top.velocity          += acceleration_y*0.25
    paddle_right_top.sprite_position.y -= acceleration_y + paddle_right_top.velocity
    paddle_right_top.velocity          *= friction

    paddle_bot.sprite_position.x        = mid(min_pos, paddle_bot.sprite_position.x, max_pos)
    paddle_top.sprite_position.x        = mid(min_pos, paddle_top.sprite_position.x, max_pos)
    paddle_left_bot.sprite_position.y   = mid(half_pos, paddle_left_bot.sprite_position.y, max_pos)
    paddle_right_bot.sprite_position.y  = mid(half_pos, paddle_right_bot.sprite_position.y, max_pos)
    paddle_left_top.sprite_position.y   = mid(min_pos, paddle_left_top.sprite_position.y, half_pos-8)
    paddle_right_top.sprite_position.y  = mid(min_pos, paddle_right_top.sprite_position.y, half_pos-8)
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
    spr(ball.sprite, ball.sprite_position.x, ball.sprite_position.y)
    --pset(paddle_bot_x+4, paddle_bot_y-8, 7)
    --pset(127,127,12)
    --pset(0,127,12)
    --pset(ball.sprite_position.x, ball.sprite_position.y, 12)
    --pset(ball.real_position.min_x, ball.real_position.min_y, 3)
    --pset(ball.real_position.max_x, ball.real_position.max_y, 3)
    --[[line(ball.real_position.min_x + 0.5, ball.real_position.min_y + 0.5, 
        (ball.real_position.min_x + 0.5) + ball.direction.x*5, 
        (ball.real_position.min_y + 0.5) + ball.direction.y*5, 8)
        --]]
    --print('hello', 12)
    --print('hello\njoe', 64, 64, 12)
    print_dialogue()
end
