function init()
    RegisterTool("prism_sword", "Prism Sword", "MOD/vox/prism_sword.vox")
	SetBool("game.tool.prism_sword.enabled", true)

    hitSnd = LoadSound("MOD/snd/hit.ogg")

    animation_progress = 0
    animation_length = 20
end

function randomVector(min_val, max_val)
    result = {}
    for i=1,3 do
        result[i] = min_val + math.random() * (max_val - min_val)
    end
    return result
end

function tick(dt)
    if GetString("game.player.tool") == "prism_sword" then
        if GetBool("game.player.canusetool") and InputDown("usetool") and animation_progress == 0 then

            local camera_transform = GetCameraTransform()
            local camera_vertical_vector = TransformToParentVec(camera_transform, Vec(0, 0, -1))
            local range = 5

            local hit, dist, _, _ = QueryRaycast(camera_transform.pos, camera_vertical_vector, range)

            animation_progress = 1

            if hit then
                local hit_vector = VecAdd(camera_transform.pos, VecScale(camera_vertical_vector, dist))
                MakeHole(hit_vector, 2, 1, 0.6, true)

                PlaySound(hitSnd)

                local trace_colors = {{153, 0, 0}, {255, 255, 0}, {102, 204, 0}, {0, 255, 255}}
                local trace_spread = 1
                local trace_size = 2

                for i, v in ipairs(trace_colors) do
                    PaintRGBA(VecAdd(hit_vector, randomVector(-trace_spread, trace_spread)), trace_size, v[1], v[2], v[3], 1.0)
                end
            end

            local player_transform = GetPlayerTransform()
            local player_forward_vector = TransformToParentVec(player_transform, Vec(0, 0, -1))

            local player_push_force = 15
            SetPlayerVelocity(VecScale(player_forward_vector, player_push_force))
        end
	end

    if animation_progress > 0 then
        if animation_progress <= animation_length / 2 then
            local offset = Transform(Vec(-animation_progress / 10, 0, -animation_progress / 10))
            SetToolTransform(offset)
        else
            local offset = Transform(Vec((animation_progress - animation_length / 2) / 10 - animation_length / 2 / 10, 0, (animation_progress - animation_length / 2) / 10 - animation_length / 2 / 10))
            SetToolTransform(offset)
        end

        animation_progress = (animation_progress+1) % animation_length
    end
end
