//-----------------------------------------------------------------------------------------------
//
//Server/Client side script for Weapon Alerts
//
//@author Deven Ronquillo
//@version 
//-----------------------------------------------------------------------------------------------

if SERVER then

	AddCSLuaFile("init_weaponalert.lua")

	print("---LOADING---	sn_weaponalert")
end


if CLIENT then

	armedWarningMat = Material("materials/textures/sn_weaponalert/gunalert.png")

	armedPlayers = {}
	validWeapons = {"cw_ak74","cw_ar15","cw_extrema_ratio_official","cw_flash_grenade", "cw_fiveseven", "cw_scarh",
					"cw_frag_grenade", "cw_g3a3", "cw_g18", "cw_g36c", "cw_ump45", "cw_mp5", "cw_kk_hk416", "cw_deagle",
					"cw_l115", "cw_l85a2", "cw_m14", "cw_m1911", "cw_m249_official", "cw_m3super90", "cw_mac11", "cw_mr96",
					"cw_p99", "cw_makarov", "cw_shorty", "cw_smoke_grenade", "cw_vss", "cw_ws_scifi_aug", "cw_k1s", "cw_scifi_pistol",
					"cwc_fate"
				}

	thinkInterval = 1



	


	local function ArmedPlayersCheckThink()

		--print("---checking for armed players...")

		for k, v in pairs(player.GetAll()) do

			--print("Checking player: "..v:Nick())

			if IsValid(v) && LocalPlayer():GetPos():Distance(v:GetPos()) <= 600 then

				local equipedWeapon = nil

				if IsValid(v) && v:Alive() then

					equipedWeapon = v:GetActiveWeapon():GetClass()
				else return end
				armed = false

				for key, value in pairs(validWeapons) do

					--print("\nEquiped weapon:"..equipedWeapon)
					--print("Checking against: "..value)

					if equipedWeapon == value then

						--print("\nPlayer is armed! checking table eligability...\n")

						armed = true
					end
				end

				--print("armed value: ")
				--print(armed)

				if !table.HasValue(armedPlayers, v:SteamID64()) and armed then

					--print("Adding player to table.")

					table.insert(armedPlayers, v:SteamID64())
				end
				if table.HasValue(armedPlayers, v:SteamID64()) and !armed then

					--print("Removing player from table.")

					table.RemoveByValue(armedPlayers,v:SteamID64())
				end

				--PrintTable(armedPlayers)
			end
		end
	end









	local function drawWarning()

		


		for k, v in pairs(armedPlayers) do

			--print("starting drawing...\n")
			--print("checking player: ")
			--print(v.."\n")

			if !IsValid(player.GetBySteamID64( v )) || !(player.GetBySteamID64( v ):Alive()) then return end

			--print("player valid")
			--print("drawing...")

			local offset = Vector( 0, 0, -25)

			local attach_id = player.GetBySteamID64( v ):LookupAttachment( 'eyes' )
			if not attach_id then return end

			local attach = player.GetBySteamID64( v ):GetAttachment( attach_id )

			if not attach then return end
			
			local playerPos = attach.Pos + offset

			
			local ang = LocalPlayer():GetAngles()

			ang.y = LocalPlayer():GetAngles().y
			ang.p = - 90

			ang:RotateAroundAxis( ang:Up(), -90)

			

			cam.Start3D2D( playerPos, ang, 1 )

				surface.SetDrawColor( 255, 255, 255, (CurTime()*300 % 255)*.2 )
				surface.SetMaterial(armedWarningMat)
				surface.DrawTexturedRect( -5, -65, 10, 10)
			cam.End3D2D()
		end
	end
	hook.Add( "PreDrawEffects", "DrawArmedIcon", drawWarning)








	local function Initialize()

		timer.Create("armedPlayersCheckTimer", thinkInterval, 0, ArmedPlayersCheckThink)
	end
	hook.Add("Initialize", "Initializesnweaponalert", Initialize)
end

