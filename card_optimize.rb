#!/usr/bin/ruby

$logging = true

class Statuses
  attr_accessor :kougeki_value,     # 攻撃力
                :kougeki_percent,   # 攻撃%
                :bairitsu,          # ダメージ倍率%
                :kaishin_damage,    # 会心ダメージ%
                :boss_damage,       # ボスダメ%
                :bougyo_mushi,      # 防御無視%
                :ijou_damage,       # 異常タゲダメ%
                :high_damage,       # 高HPダメ%
                :low_damage,        # 低HPダメ%
                :iatsu              # 威圧

  def initialize(values = {})
    default_values = {
      kougeki_value: 0, kougeki_percent: 0, bairitsu: 0, kaishin_damage: 0, boss_damage: 0, bougyo_mushi: 0,
      ijou_damage: 0, high_damage: 0, low_damage: 0, iatsu: 0
    }
    values = default_values.merge(values)
    @kougeki_value   = values[:kougeki_value]
    @kougeki_percent = values[:kougeki_percent]
    @bairitsu        = values[:bairitsu]
    @kaishin_damage  = values[:kaishin_damage]
    @boss_damage     = values[:boss_damage]
    @bougyo_mushi    = values[:bougyo_mushi]
    @ijou_damage     = values[:ijou_damage]
    @high_damage     = values[:high_damage]
    @low_damage      = values[:low_damage]
    @iatsu           = values[:iatsu]
  end

  def add(other)
    @kougeki_value   += other.kougeki_value
    @kougeki_percent += other.kougeki_percent
    @bairitsu        += other.bairitsu
    @kaishin_damage  += other.kaishin_damage
    @boss_damage     += other.boss_damage
    @bougyo_mushi    += other.bougyo_mushi
    @ijou_damage     += other.ijou_damage
    @high_damage     += other.high_damage
    @low_damage      += other.low_damage
    @iatsu           += other.iatsu
  end

  def self.sum(statuses_array)
    result = Statuses.new()
    statuses_array.each{ |statuses|
      result.add(statuses)
    }
    return result
  end

  # ダメージ量評価（いわゆるダメージ計算式）
  def eval
    ((@kougeki_value * (1 + @kougeki_percent.to_f/100)) *
     ((@kaishin_damage.to_f/100 * 0.8) + 0.2) *
     (1 + @boss_damage.to_f/100) *
     (1 + (@iatsu + ([@bougyo_mushi-70 ,0].max*3)).to_f/1000) *
     (1 + (@ijou_damage.to_f/100 + @high_damage.to_f/200 + @low_damage.to_f/200)) *
     (@bairitsu.to_f/100)
    )
  end
end

class Card
  attr_accessor :id, :name, :main_statuses, :sub_statuses
  @@id_counter = 0

  def initialize(name, main_statuses, sub_statuses = {})
    @id = generate_next_id
    @name = name
    @main_statuses = Statuses.new(main_statuses)
    @sub_statuses = Statuses.new(sub_statuses)
  end

  def generate_next_id
    @@id_counter += 1
  end
end

# キャラクターステータス
$base_statuses = Statuses.new({
  kougeki_value:   70000,
  kougeki_percent:    15,
  bairitsu:          500,
  kaishin_damage:    325,
  boss_damage:        50,
  bougyo_mushi:      100,
  ijou_damage:        50,
  high_damage:       110,
  low_damage:        100,
  iatsu:            1600,
})

# 候補のカード一覧
# これもインビジブルさんのシートから、赤３以上の赤カードをピックアップ
cards = [
  Card.new("ディズワット"  , {kougeki_percent: 2}                              , {kougeki_percent: 1}),
  Card.new("レイ"          , {kougeki_percent: 2, bairitsu: 4, bougyo_mushi: 5}, {kougeki_percent: 1, bougyo_mushi: 2}),
  Card.new("エドガー"      , {kougeki_percent: 1, bairitsu: 4, ijou_damage: 6} , {kougeki_percent: 1, ijou_damage: 2}),
  Card.new("あずさ"        , {bairitsu: 6, bougyo_mushi: 7}                    , {bougyo_mushi: 3}),
  Card.new("フェンリル"    , {kougeki_percent: 1, kaishin_damage: 8}           , {kaishin_damage: 2}),
  Card.new("デーモンノーム", {high_damage: 14}                                 , {high_damage: 5}),
  Card.new("コリカルディア", {bairitsu: 4, bougyo_mushi: 12}                   , {bougyo_mushi: 6}),
  Card.new("ネクト"        , {bairitsu: 7, low_damage: 13}                     , {bairitsu: 4, low_damage: 6}),
  Card.new("ウィット"      , {bairitsu: 10}                                    , {bairitsu: 3}),
  Card.new("リュネット"    , {low_damage: 15}                                  , {low_damage: 5}),
  Card.new("ペルシーク"    , {kaishin_damage: 11}                              , {kaishin_damage: 5}),
  Card.new("トレーシアＲ"  , {bairitsu: 8, bougyo_mushi: 11}                   , {bairitsu: 3, bougyo_mushi: 5}),
  Card.new("クイン赤"      , {bairitsu: 7, kaishin_damage: 9}                  , {bairitsu: 4, kaishin_damage: 4}),
  Card.new("リンクＲ赤"    , {high_damage: 15, low_damage: 4}                  , {high_damage: 6}),
  Card.new("シエルＥ赤"    , {high_damage: 13}                                 , {high_damage: 6}),

  # 水増し用
  Card.new("ディズワット"  , {kougeki_percent: 2}                              , {kougeki_percent: 1}),
  Card.new("レイ"          , {kougeki_percent: 2, bairitsu: 4, bougyo_mushi: 5}, {kougeki_percent: 1, bougyo_mushi: 2}),
  Card.new("エドガー"      , {kougeki_percent: 1, bairitsu: 4, ijou_damage: 6} , {kougeki_percent: 1, ijou_damage: 2}),
  Card.new("あずさ"        , {bairitsu: 6, bougyo_mushi: 7}                    , {bougyo_mushi: 3}),
  Card.new("フェンリル"    , {kougeki_percent: 1, kaishin_damage: 8}           , {kaishin_damage: 2}),
  Card.new("デーモンノーム", {high_damage: 14}                                 , {high_damage: 5}),
  Card.new("コリカルディア", {bairitsu: 4, bougyo_mushi: 12}                   , {bougyo_mushi: 6}),
  Card.new("ネクト"        , {bairitsu: 7, low_damage: 13}                     , {bairitsu: 4, low_damage: 6}),
  Card.new("ウィット"      , {bairitsu: 10}                                    , {bairitsu: 3}),
  Card.new("リュネット"    , {low_damage: 15}                                  , {low_damage: 5}),
  Card.new("ペルシーク"    , {kaishin_damage: 11}                              , {kaishin_damage: 5}),
  Card.new("トレーシアＲ"  , {bairitsu: 8, bougyo_mushi: 11}                   , {bairitsu: 3, bougyo_mushi: 5}),
  Card.new("クイン赤"      , {bairitsu: 7, kaishin_damage: 9}                  , {bairitsu: 4, kaishin_damage: 4}),
  Card.new("リンクＲ赤"    , {high_damage: 15, low_damage: 4}                  , {high_damage: 6}),
  Card.new("シエルＥ赤"    , {high_damage: 13}                                 , {high_damage: 6}),
  Card.new("ディズワット"  , {kougeki_percent: 2}                              , {kougeki_percent: 1}),
  Card.new("レイ"          , {kougeki_percent: 2, bairitsu: 4, bougyo_mushi: 5}, {kougeki_percent: 1, bougyo_mushi: 2}),
  Card.new("エドガー"      , {kougeki_percent: 1, bairitsu: 4, ijou_damage: 6} , {kougeki_percent: 1, ijou_damage: 2}),
  Card.new("あずさ"        , {bairitsu: 6, bougyo_mushi: 7}                    , {bougyo_mushi: 3}),
  Card.new("フェンリル"    , {kougeki_percent: 1, kaishin_damage: 8}           , {kaishin_damage: 2}),
  Card.new("デーモンノーム", {high_damage: 14}                                 , {high_damage: 5}),
  Card.new("コリカルディア", {bairitsu: 4, bougyo_mushi: 12}                   , {bougyo_mushi: 6}),
  Card.new("ネクト"        , {bairitsu: 7, low_damage: 13}                     , {bairitsu: 4, low_damage: 6}),
  Card.new("ウィット"      , {bairitsu: 10}                                    , {bairitsu: 3}),
  Card.new("リュネット"    , {low_damage: 15}                                  , {low_damage: 5}),
  Card.new("ペルシーク"    , {kaishin_damage: 11}                              , {kaishin_damage: 5}),
  Card.new("トレーシアＲ"  , {bairitsu: 8, bougyo_mushi: 11}                   , {bairitsu: 3, bougyo_mushi: 5}),
  Card.new("クイン赤"      , {bairitsu: 7, kaishin_damage: 9}                  , {bairitsu: 4, kaishin_damage: 4}),
  Card.new("リンクＲ赤"    , {high_damage: 15, low_damage: 4}                  , {high_damage: 6}),
  Card.new("シエルＥ赤"    , {high_damage: 13}                                 , {high_damage: 6}),
  Card.new("ディズワット"  , {kougeki_percent: 2}                              , {kougeki_percent: 1}),
  Card.new("レイ"          , {kougeki_percent: 2, bairitsu: 4, bougyo_mushi: 5}, {kougeki_percent: 1, bougyo_mushi: 2}),
  Card.new("エドガー"      , {kougeki_percent: 1, bairitsu: 4, ijou_damage: 6} , {kougeki_percent: 1, ijou_damage: 2}),
  Card.new("あずさ"        , {bairitsu: 6, bougyo_mushi: 7}                    , {bougyo_mushi: 3}),
  Card.new("フェンリル"    , {kougeki_percent: 1, kaishin_damage: 8}           , {kaishin_damage: 2}),
  Card.new("デーモンノーム", {high_damage: 14}                                 , {high_damage: 5}),
  Card.new("コリカルディア", {bairitsu: 4, bougyo_mushi: 12}                   , {bougyo_mushi: 6}),
  Card.new("ネクト"        , {bairitsu: 7, low_damage: 13}                     , {bairitsu: 4, low_damage: 6}),
  Card.new("ウィット"      , {bairitsu: 10}                                    , {bairitsu: 3}),
  Card.new("リュネット"    , {low_damage: 15}                                  , {low_damage: 5}),
  Card.new("ペルシーク"    , {kaishin_damage: 11}                              , {kaishin_damage: 5}),
  Card.new("トレーシアＲ"  , {bairitsu: 8, bougyo_mushi: 11}                   , {bairitsu: 3, bougyo_mushi: 5}),
  Card.new("クイン赤"      , {bairitsu: 7, kaishin_damage: 9}                  , {bairitsu: 4, kaishin_damage: 4}),
  Card.new("リンクＲ赤"    , {high_damage: 15, low_damage: 4}                  , {high_damage: 6}),
  Card.new("シエルＥ赤"    , {high_damage: 13}                                 , {high_damage: 6}),
]

$hash_cards = cards.map{ |card| [card.id, card] }.to_h

MAIN_SIZE = 16   # メインカードの枚数
SUB_SIZE  =  8   # サブカードの枚数

# 現在のカード情報を表示（標準出力に出さない場合は不要）
def print_cards(ids, delta, replace_id = {})
  unless $logging
    return
  end

  main_ids = ids[0..MAIN_SIZE-1]
  sub_ids  = ids[-SUB_SIZE..-1]
  (main_ids.sort_by{ |id| delta[ids.index(id)] } + sub_ids.sort_by{ |id| delta[ids.index(id)] }).each_with_index{ |id, index|
    suffix = ((replace_id.key?(id)) ? " => #{$hash_cards[replace_id[id]].name}" : "")
    puts sprintf("%c %s : %.4f %s", (index < MAIN_SIZE ? 'M' : 'S'), $hash_cards[id].name, delta[ids.index(id)], suffix)
  }
end

# メインとサブのステータス配列を取得
def get_statuses_array(ids)
  statuses_array = []
  ids.each_with_index{ |id, index|
    statuses_array << ((index < MAIN_SIZE) ? $hash_cards[id].main_statuses : $hash_cards[id].sub_statuses)
  }
  return statuses_array
end

# ids の評価値を取得
def evaluate(ids)
  Statuses.sum(get_statuses_array(ids) + [$base_statuses]).eval
end

# デルタ（各カードを外した場合から比べての増分割合）を取得
def get_delta(ids)
  eval_current = evaluate(ids)
  delta = {}
  ids.each_with_index{ |id_, index|
    statuses_array = get_statuses_array(ids)
    statuses_array[index] = Statuses.new
    delta[index] = eval_current / Statuses.sum(statuses_array + [$base_statuses]).eval
  }
  return delta
end

# 勾配法のワンステップ実行
def grad_step(ids)
  eval_current = evaluate(ids)
  delta = get_delta(ids)

  sorted_index = delta.keys.sort_by{ |key| delta[key] }
  sorted_index.each{ |index|
    id_alt = nil
    eval_candidate_max = eval_current
    ($hash_cards.keys - ids).each{ |id_candidate|
      ids_candidate = ids.dup
      ids_candidate[index] = id_candidate
      eval_candidate = evaluate(ids_candidate)
      if eval_candidate > eval_candidate_max
        id_alt = id_candidate
        eval_candidate_max = eval_candidate
      end
    }
    if id_alt
      print_cards(ids, delta, {ids[index] => id_alt})
      ids[index] = id_alt
      return ids
    end
  }

  print_cards(ids, delta)
  return nil
end

# 勾配法で行き詰まるまで最適化
def grad_optimize(ids)
  while grad_step(ids)
    puts "----" if $logging
  end
  evaluate(ids)
end

# メイン/サブ 入れ替えによる変異
def transmutate(ids)
  $logging = false
  eval_original = evaluate(ids)
  (0..MAIN_SIZE-1).each{ |n|
    (MAIN_SIZE..(MAIN_SIZE+SUB_SIZE-1)).each{ |m|
      ids_trans = ids.dup
      ids_trans[n] = ids[m]
      ids_trans[m] = ids[n]
      if grad_optimize(ids_trans) > eval_original
        $logging = true
        puts "Transmutate!"
        print_cards(ids_trans, get_delta(ids_trans))
        return ids_trans
      end
    }
  }
  $logging = true
  return ids
end


# 初期値はランダムに
ids = cards.map{|c| c.id}.sample(MAIN_SIZE + SUB_SIZE)
p ids

# 世代ループ。念のため上限100
for generation in 1..100 do
  puts "--------"
  puts "Generation #{generation}"
  grad_top = grad_optimize(ids)
  ids_trans = transmutate(ids)
  p Math.log2(evaluate(ids))

  # 評価値が変化しなかったら終わり
  if ids == ids_trans
    break
  end
  ids = ids_trans
end
