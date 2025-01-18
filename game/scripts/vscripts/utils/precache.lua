local particles = 
{
    "particles/units/heroes/hero_techies/techies_suicide.vpcf",
    "particles/econ/events/ti10/hot_potato/hot_potato_debuff.vpcf",
    "particles/potato_debuff.vpcf",
    "particles/units/heroes/hero_dark_seer/dark_seer_punch_glove_attack.vpcf",
    "particles/units/heroes/hero_tusk/tusk_walruspunch_txt.vpcf",
    "particles/dice_particle.vpcf",
    "particles/leader/leader_overhead.vpcf",
    "particles/generic_gameplay/generic_lifesteal.vpcf",
    "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf",
    "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf",
    "particles/step_particle_stack.vpcf",
    "particles/cup_down.vpcf",
    "particles/units/heroes/hero_ringmaster/ringmaster_spotlight_lightshaft.vpcf",
    "particles/sniper_q/sniper_q.vpcf",
    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf",
    "particles/target_ground/particle_1.vpcf",
    "particles/point_ring_effect.vpcf",
    "particles/units/heroes/hero_oracle/oracle_false_promise_heal.vpcf",
    "particles/item_6.vpcf",
    "particles/crown_reached.vpcf",
    "particles/units/heroes/hero_faceless_void/faceless_void_time_walk_preimage.vpcf",
    "particles/soul/thresh_base_passive_soul.vpcf",
    "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf",
    "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
    "particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_proj.vpcf",
}

local sounds = 
{
    "soundevents/game_sounds_pummel.vsndevts",
}

local models = 
{

}

return function(context)
    for _, obj in pairs(particles) do
        PrecacheResource("particle", obj, context)
    end
    for _, obj in pairs(sounds) do
        PrecacheResource("soundfile", obj, context)
    end
    for _, obj in pairs(models) do
        PrecacheResource("model", obj, context)
    end
    PrecacheResource( "particle_folder", "particles/neutral_fx/", context )
    PrecacheResource( "particle_folder", "particles/items_fx/", context )
    PrecacheResource( "particle_folder", "particles/items5_fx/", context )
    PrecacheResource( "particle_folder", "particles/items4_fx/", context )
    PrecacheResource( "particle_folder", "particles/items3_fx/", context )
    PrecacheResource( "particle_folder", "particles/items2_fx/", context )
    PrecacheResource( "particle_folder", "particles/units/heroes/hero_ancient_apparition/", context )
    PrecacheResource( "particle_folder", "particles/units/heroes/hero_snapfire/", context )
    PrecacheResource( "particle_folder", "particles/units/heroes/hero_queenofpain/", context )
    PrecacheResource( "particle_folder", "particles/units/heroes/hero_invoker/", context )
    local heroes = LoadKeyValues("scripts/npc/activelist.txt")
    for k,v in pairs(heroes) do
        PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context )  
        PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_" .. k:gsub('npc_dota_hero_','') ..".vsndevts", context ) 
    end
end

