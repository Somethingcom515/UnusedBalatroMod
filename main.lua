SMODS.Atlas{
    key = 'Decks',
    path = 'Decks.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'Vouchers',
    path = 'Vouchers.png',
    px = 71,
    py = 95,
}

SMODS.Back{
    key = 'braided',
    loc_txt = {
        name = 'Braided Deck',
        text = {
            "Most played hand",
            "starts at {C:attention}lvl.#1#{}",
        }
    },
    atlas = 'Decks',
    pos = {x = 0, y = 0},
    config = {
        level = 3
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {self.config.level}}
    end,
    apply = function(self, back)
        print(tprint(G.PROFILES[G.SETTINGS.profile]))
    end
}

SMODS.Back{
    key = 'silver',
    loc_txt = {
        name = 'Silver Deck',
        text = {
            "Start run with",
            "one {C:attention}Joker{}",
        }
    },
    atlas = 'Decks',
    pos = {x = 1, y = 0},
    apply = function(self, back)
		G.E_MANAGER:add_event(Event({
			func = function()
				if G.jokers then
					local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "sil")
                    joker:add_to_deck()
                    joker:start_materialize()
					G.jokers:emplace(joker)
					return true
				end
			end,
        }))
    end
}

SMODS.Voucher{
    key = 'pattern',
    name = 'Pattern',
    loc_txt = {
        name = 'Pattern',
        text = {
            'Spawns your {C:attention}all time{}',
            'most used {C:tarot}Tarot{}/{C:planet}Planet{} card,',
            'if you have room',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers', --- paper shiller dont sue me
    pos = { x = 2, y = 0 },
    redeem = function(self, card)
        local used_cards = {}
        local max_amt = 0
        for k, v in pairs(G.PROFILES[G.SETTINGS.profile]['consumeable_usage']) do
            if G.P_CENTERS[k] and G.P_CENTERS[k].discovered and G.P_CENTERS[k].set and (G.P_CENTERS[k].set == 'Tarot' or G.P_CENTERS[k].set == 'Planet') then
            used_cards[#used_cards + 1] = {count = v.count, key = k, set = G.P_CENTERS[k].set}
            if v.count > max_amt then max_amt = v.count end
            end
        end
        table.sort(used_cards, function (a, b) return a.count > b.count end )
        local mostusedtarotplanet = used_cards[1]
        if mostusedtarotplanet and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then -- room?
            local card_ = create_card(mostusedtarotplanet.set, G.consumeables, nil, nil, nil, nil, mostusedtarotplanet.key, "patt")
            card_:add_to_deck()
            G.consumeables:emplace(card_)
        end
    end
}

SMODS.Voucher{
    key = 'tesselation',
    name = 'Tesselation',
    loc_txt = {
        name = 'Tesselation',
        text = {
            'Spawns your {C:attention}all time{}',
            'most used {C:attention}Joker{} card,',
            'if you have room',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers', --- paper shiller dont sue me
    requires = {'v_ubm_pattern'},
    pos = { x = 3, y = 0 },
    redeem = function(self, card)
        local used_cards = {}
        local max_amt = 0
        for k, v in pairs(G.PROFILES[G.SETTINGS.profile]['joker_usage']) do
            if G.P_CENTERS[k] and G.P_CENTERS[k].discovered then
            used_cards[#used_cards + 1] = {count = v.count, key = k}
            if v.count > max_amt then max_amt = v.count end
            end
        end
        table.sort(used_cards, function (a, b) return a.count > b.count end )
        local mostusedjoker = used_cards[1]
        if mostusedjoker and (#G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit) then -- room?
            local card_ = create_card("Joker", G.jokers, nil, nil, nil, nil, mostusedjoker.key, "patt")
            card_:add_to_deck()
            G.jokers:emplace(card_)
        end
    end
}

SMODS.Voucher{
    key = 'silverspoon',
    name = 'SilverSpoon',
    loc_txt = {
        name = 'Silver Spoon',
        text = {
            'Start your {C:attention}next run{}',
            'with a bonus of {C:money}$5{}',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers', --- paper shiller dont sue me
    pos = { x = 4, y = 0 },
    config = {money = 5},
    redeem = function(self, card)
        G.PROFILES[G.SETTINGS.profile].silverspoon_money = card.ability.money
    end
}

local oldstartrun = Game.start_run
function Game:start_run(args)
    local g = oldstartrun(self, args)
    if G.PROFILES[G.SETTINGS.profile].silverspoon_money then
        G.GAME.dollars = G.GAME.dollars + G.PROFILES[G.SETTINGS.profile].silverspoon_money
        G.PROFILES[G.SETTINGS.profile].silverspoon_money = nil
    end
    return g
end