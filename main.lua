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
        G.E_MANAGER:add_event(Event({
			func = function()
                if G.playing_cards then
                    for k, v in pairs(G.GAME.hands) do
                        if k == G.GAME.current_round.most_played_poker_hand then
                            level_up_hand(self, k, true, self.config.level - 1)
                        end
                    end
                    return true
                end
            end
        }))
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

SMODS.Back{
    key = 'foil',
    loc_txt = {
        name = 'Foil Deck',
        text = {
            "Add {C:dark_edition}Foil{} to {C:attention}#1#{}",
            "random cards in deck",
        }
    },
    atlas = 'Decks',
    pos = {x = 2, y = 0},
    config = {
        cards = 3
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {self.config.cards}}
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.playing_cards then
                    for i = 1, self.config.cards do
                        (pseudorandom_element(G.playing_cards, pseudoseed('foil'..i))):set_edition({foil = true}, true, true)
                    end
                    return true
                end
            end,
        }))
    end
}

SMODS.Back{
    key = 'holographic',
    loc_txt = {
        name = 'Holographic Deck',
        text = {
            "Add {C:dark_edition}Holographic{} to {C:attention}#1#{}",
            "random cards in deck",
        }
    },
    atlas = 'Decks',
    pos = {x = 3, y = 0},
    config = {
        cards = 2
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {self.config.cards}}
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.playing_cards then
                    for i = 1, self.config.cards do
                        (pseudorandom_element(G.playing_cards, pseudoseed('holographic'..i))):set_edition({holo = true}, true, true)
                    end
                    return true
                end
            end,
        }))
    end
}

SMODS.Back{
    key = 'polychrome',
    loc_txt = {
        name = 'Polychrome Deck',
        text = {
            "Add {C:dark_edition}Polychrome{} to {C:attention}#1#{}",
            "random cards in deck",
        }
    },
    atlas = 'Decks',
    pos = {x = 3, y = 0},
    config = {
        cards = 1
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {self.config.cards}}
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.playing_cards then
                    for i = 1, self.config.cards do
                        (pseudorandom_element(G.playing_cards, pseudoseed('polychrome'..i))):set_edition({polychrome = true}, true, true)
                    end
                    return true
                end
            end,
        }))
    end
}

local oldshuffle = CardArea.shuffle
function CardArea:shuffle(_seed)
    local g = oldshuffle(self, _seed)
    if self == G.deck and G.GAME.used_vouchers.v_ubm_magnet and not G.GAME.used_vouchers.v_ubm_electromagnet then
        local prioritys = {}
        local otherones = {}
        local temptimes = 0
        local card
        for k, v in pairs(self.cards) do
            if v.base.times_played and temptimes then
                if v.base.times_played > temptimes then
                    temptimes = v.ability.times_played
                    card = v
                end
            end
        end
        for k, v in pairs(self.cards) do
            if v == card then
                table.insert(prioritys, v)
            else
                table.insert(otherones, v)
            end
        end
        for _, card in ipairs(prioritys) do
            table.insert(otherones, card)
        end
        self.cards = otherones
        self:set_ranks()
    end
    if self == G.deck and G.GAME.used_vouchers.v_ubm_electromagnet then
        local prioritys = {}
        local otherones = {}
        local temptimes = 0
        local card
        local topCards = {}
        for k, v in pairs(self.cards) do
            if v.base.times_played and temptimes then
                if #topCards < 3 or (v.base.times_played > topCards[3].base.times_played) then
                    table.insert(topCards, v)
                    table.sort(topCards, function(a, b) return a.base.times_played > b.base.times_played end)
                    if #topCards > 3 then
                        table.remove(topCards, 3)
                    end
                end
            end
        end
        print(topCards)
        for k, v in pairs(self.cards) do
            if v == topCards[1] or v == topCards[2] or v == topCards[3] then
                table.insert(prioritys, v)
            else
                table.insert(otherones, v)
            end
        end
        for _, card in ipairs(prioritys) do
            table.insert(otherones, card)
        end
        self.cards = otherones
        self:set_ranks()
    end
    return g
end

SMODS.Voucher{
    key = 'magnet',
    name = 'Magnet',
    loc_txt = {
        name = 'Magnet',
        text = {
            'Your {C:attention}most played{} card',
            'this run is {C:attention}always{} drawn',
            'to hand, when {C:attention}Blind{} is selected',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers',
    pos = { x = 0, y = 0 },
}

SMODS.Voucher{
    key = 'electromagnet',
    name = 'Electromagnet',
    loc_txt = {
        name = 'Electromagnet',
        text = {
            'Your 3 {C:attention}most played{} cards',
            'this run are {C:attention}always{} drawn',
            'to hand, when {C:attention}Blind{} is selected',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers',
    pos = { x = 1, y = 0 },
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
    atlas = 'Vouchers',
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
            'with a bonus of {C:money}$#1#{}',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers', --- paper shiller dont sue me
    pos = { x = 4, y = 0 },
    config = {money = 5},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.money}}
    end,
    redeem = function(self, card)
        G.PROFILES[G.SETTINGS.profile].silverspoon_money = card.ability.money
    end
}

SMODS.Voucher{
    key = 'heirloom',
    name = 'Heirloom',
    loc_txt = {
        name = 'Heirloom',
        text = {
            'Start your {C:attention}next run{}',
            'with a bonus of {C:money}$#1#{}',
        }
    },
    unlocked = true,
    discovered = true,
    atlas = 'Vouchers', --- paper shiller dont sue me
    pos = { x = 5, y = 0 },
    config = {money = 15},
    requires = {'v_ubm_silverspoon'},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.money}}
    end,
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