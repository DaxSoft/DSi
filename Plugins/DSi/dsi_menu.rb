#==============================================================================
# • DSi Default Menu
#==============================================================================
# Autor: Dax
# Versão: 1.0
# Site: www.dax-soft.weebly.com
# Requerimento: Dax Core
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Menu padrão do sistema DSi.
#==============================================================================
# • Versões:
#------------------------------------------------------------------------------
# 1.0 :
#   - Comandos padrões do maker. Padronizado ao estilo DSi.
#==============================================================================
Dax.register(:dsi_default_menu, "dax", 1.0, [[:dsi, "dax"]]) {
Dax.remove(:Scene_Menu)
#==============================================================================
# • Configuração.
#==============================================================================
module DS::Menu
  #----------------------------------------------------------------------------
  # • Configuração GERAL.
  #----------------------------------------------------------------------------
  SCROLLBAR_COLOR = "ffffff"
  SKIN_MENU = "dsi menu skyrim"                    # Skin do menu.
  BACKBAR = "BackBar"
  HPBAR = "HpBar"
  MPBAR = "MpBar"
  XPBAR = "XpBar"
  CURSOR = "Cursor"
  #----------------------------------------------------------------------------
  # • Configuração do menu padrão.
  #----------------------------------------------------------------------------
  MENU = {
    # Jogador parar ao ativar os menu. $game_player.no_movable = TRUE/FALSE
    stop_walk:                  true,
  }
  #----------------------------------------------------------------------------
  # • Configuração das opções do menu.
  #----------------------------------------------------------------------------
  OPTION_COMMAND = [ # Defina aqui as opções do menu.
    #[Nome da imagem, Scene]
    ["oitem", "Scene_Item"],
    ["oskill", "Scene_Skill"],
    ["oequip", "Scene_Equip"],
    ["osystem", nil],
  ]
end
#==============================================================================
# • Cache
#==============================================================================
class << Cache
  #--------------------------------------------------------------------------
  # * Carregamento dos gráficos em geral (Menu)
  #     filename : nome do arquivo
  #--------------------------------------------------------------------------
  def menu(filename)
    load_bitmap("./Graphics/Menu/", filename)
  end
end
#==============================================================================
# • DS::Menu::Bar
#==============================================================================
class DS::Menu::Bar < Sprite
  include DS::Menu
  attr_accessor :current, :current_max
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize(sym, current, current_max, x, y)
    super(nil)
    self.x, self.y = x, y
    self.bitmap = Cache.menu(BACKBAR)
    @bitmap = Cache.menu(whatbar(sym))
    @bar = Sprite.new([self.width, self.height])
    @current, @current_max = current, current_max
    update
  end

  def whatbar(sym)
    case sym
    when :hp
      return HPBAR
    when :mp
      return MPBAR
    when :xp
      return XPBAR
    end
  end

  #----------------------------------------------------------------------------
  # • Renovação dos objetos.
  #----------------------------------------------------------------------------
  def dispose
    @bar.bitmap.dispose
    self.bitmap.dispose
    @bitmap.dispose
    @bar.dispose
    super
  end
  #----------------------------------------------------------------------------
  # • Atualização dos objetos.
  #----------------------------------------------------------------------------
  def update
    @bar.z = self.z + 5
    @bar.x, @bar.y = self.x + 11, self.y + 3
    @bar.bitmap.clear
    rect = Rect.new(0, 0, self.width.to_p(@current, @current_max), self.height)
    @bar.bitmap.blt(0, 0, @bitmap, rect)
  end

  def pos(x, y)
    self.x, self.y = x, y
  end

  def op=(val,ac=false)
    [@bar, self].each { |i|
      i.opacity = val unless ac
      i.opacity += val if ac
    }
  end

  def opa(val)
    [@bar, self].each { |i|
      i.opacity += val unless i.opacity >= 255 or i.opacity < 0
    }
  end
end
#==============================================================================
# • DS::Menu::IconStats
#==============================================================================
class DS::Menu::IconStats < Sprite
  TIME = 20
  attr_accessor :user
  def initialize(user, x, y, z=DS.z+15)
    @current = 0
    @user = user
    super([24, 24, x, y, z])
    @time = 0
    @icons = (@user.state_icons + @user.buff_icons)[0, 24]
    bitmap.draw_icon(@icons[0], 0, 0)
  end
  def dispose
    self.bitmap.dispose
    super
  end
  def update
    if @time > TIME
      bitmap.clear
      @current = @current.next % (@user.state_icons + @user.buff_icons)[0, 24].size rescue 0
      bitmap.draw_icon((@user.state_icons + @user.buff_icons)[0, 24][@current], 0, 0)
      @time = 0
    else
      @time += 1
    end
  end
end
#==============================================================================
# • Scene_Menu
#==============================================================================
class Scene_Menu
  include DS::Menu
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def initialize
    @actor_index = 0
    @option = []
    @option_index = 0
    @skinmenu = Sprite.new
    @skinmenu.bitmap = Cache.menu(SKIN_MENU)
    @skinmenu.z = DS.z + 1
    create_option
    create_mapname
    create_gold
    create_slq_window
    create_end_window
    create_simple_status
    @arrow_pred = Sprite.new()
    @arrow_pred.bitmap = Cache.menu CURSOR
    @arrow_pred.x = 8
    @arrow_pred.z = @skinmenu.z+10
    @arrow_pred.y = DS.height + ((DS.height - @arrow_pred.height) / 2) + 12
    @arrow_pred.opacity = 127

    @arrow_next = Sprite.new()
    @arrow_next.bitmap = Cache.menu CURSOR
    @arrow_next.x = Graphics.width - (8 + @arrow_next.width)
    @arrow_next.z = @skinmenu.z+10
    @arrow_next.y = @arrow_pred.y
    @arrow_next.opacity = 127
    @arrow_next.mirror!
  end
  #----------------------------------------------------------------------------
  # • Retorna ao usuário.
  #----------------------------------------------------------------------------
  def user
    $game_party.members[@actor_index]
  end
  #----------------------------------------------------------------------------
  # • Criar as opções.
  #----------------------------------------------------------------------------
  def create_option
    OPTION_COMMAND.each_with_index { |i, n|
      @option[n] = Sprite.new
      @option[n].bitmap = Cache.menu(i[0])
      @option[n].z = DS.z + 10
      @option[n].y = DS.height + 16
      @option[n].x = ((Graphics.width - 28 * OPTION_COMMAND.size) / 2)  + (28 * n)
      @option[n].opacity = 127
    }
  end
  #----------------------------------------------------------------------------
  # • Criar nome dos mapa.
  #----------------------------------------------------------------------------
  def create_mapname
    @mapname = Sprite.new([164, 24, 24, 0, @skinmenu.z.next])
    @mapname.position(3)
    @mapname.x = 28
    @mapname.y -= 2
    DS::FONT_PROC[@mapname.bitmap, :NORMAL]
    text = $game_map.display_name
    @mapname.bitmap.draw_text_rect(text.upcase)
  end
  #----------------------------------------------------------------------------
  # • Criar cotação de dinheiro.
  #----------------------------------------------------------------------------
  def create_gold
    @gold = Sprite_Text.new(0, 0, 96, 24, $game_party.gold.to_s, 2)
    @gold.position(5)
    @gold.z = @mapname.z
    @gold.y -= 2
    @gold.x -= 32
    DS::FONT_PROC[@gold.bitmap, :NORMAL]
    @gold.update
  end
  #--------------------------------------------------------------------------
  # * Criar Window Slq
  #--------------------------------------------------------------------------
  def create_slq_window
    @slq_window = Window_SLQ.new
    @slq_window.set_handler :save, method(:slqSave)
    @slq_window.set_handler :load, method(:slqLoad)
    @slq_window.set_handler :end, method(:slqEnd)
    @slq_window.set_handler :cancel, method(:slqCancel)
  end
  #--------------------------------------------------------------------------
  # * Comando [Para o Título]
  #--------------------------------------------------------------------------
  def slqSave
    @slq_window.close
    SceneManager.call(Scene_Save)
  end
  #--------------------------------------------------------------------------
  # * Comando [Sair]
  #--------------------------------------------------------------------------
  def slqLoad
    @slq_window.close
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # * Comando [End]
  #--------------------------------------------------------------------------
  def slqEnd
    slqCancel
    @end_window.active = true
    @end_window.open
    @end_window.visible = true
    $game_player.no_movable = MENU.get(:stop_walk)
  end
  #--------------------------------------------------------------------------
  # * Comando [Cancel]
  #--------------------------------------------------------------------------
  def slqCancel
    @slq_window.close
    @slq_window.active = false
    @slq_window.visible = false
    $game_player.no_movable = false
  end
  #----------------------------------------------------------------------------
  # • Criar janela com as opções de sair do jogo.
  #----------------------------------------------------------------------------
  def create_end_window
    @end_window = Window_GameEnd.new
    @end_window.active = false
    @end_window.close
    @end_window.visible = false
    @end_window.set_handler(:to_title, method(:endToTitle))
    @end_window.set_handler(:shutdown, method(:endShutdown))
    @end_window.set_handler(:cancel,   method(:endCancel))
  end
  #----------------------------------------------------------------------------
  # • Ir para a tela de títulos
  #----------------------------------------------------------------------------
  def endToTitle
    @end_window.close
    SceneManager.goto(Scene_Title)
  end
  #----------------------------------------------------------------------------
  # • Sair do jogo.
  #----------------------------------------------------------------------------
  def endShutdown
    @end_window.close
    SceneManager.exit
  end
  #----------------------------------------------------------------------------
  # • Cancelar
  #----------------------------------------------------------------------------
  def endCancel
    @end_window.active = false
    @end_window.close
    @end_window.visible = false
    @slq_window.open
    @slq_window.active = true
    @slq_window.visible = true
  end
  #----------------------------------------------------------------------------
  # • Criar as opções simples
  #----------------------------------------------------------------------------
  def create_simple_status
    @simple_status = Sprite.new([190, 80, 0, 0, DS.z+15])
    @simple_status.position(1)
    @simple_status.y = DS.height + 76

    @hpbar = DS::Menu::Bar.new(:hp, user.hp, user.mhp, 0, 0)
    @hpbar.z = @simple_status.z+1
    @hpbar.pos(@simple_status.x+36, @simple_status.y+20)

    @mpbar = DS::Menu::Bar.new(:mp, user.mp, user.mmp, @simple_status.x+36, @simple_status.y+40)
    @mpbar.z = @simple_status.z+1

    @xpbar = DS::Menu::Bar.new(:xp, user.exp - user.current_level_exp,
     user.next_level_exp.to_f - user.current_level_exp.to_f,
     @simple_status.x+36, @simple_status.y+60)
    @xpbar.z = @mpbar.z

    [@hpbar, @mpbar, @xpbar].each { |i| i.op = 0 }

    @pain = DS::Menu::IconStats.new(user, @simple_status.x + 6, @simple_status.y + 50)
    define_simple_status
  end
  #----------------------------------------------------------------------------
  # • Definir o status simples
  #----------------------------------------------------------------------------
  def define_simple_status
    return if user.nil?
    @simple_status.bitmap.clear
    DS::FONT_PROC[@simple_status.bitmap, :NORMAL]
    @simple_status.bitmap.font.size += 2
    @simple_status.bitmap.draw_text(0, 0, @simple_status.width, 24, user.name.upcase + " [LV #{user.level.to_s}]", 1)
    @hpbar.current = user.hp
    @hpbar.current_max = user.mhp
    @mpbar.current = user.mp
    @mpbar.current_max = user.mmp
    @xpbar.current = user.exp - user.current_level_exp
    @xpbar.current_max = user.next_level_exp.to_f - user.current_level_exp.to_f
    @pain.user = user
  end
  #----------------------------------------------------------------------------
  # • Renovação dos objetos.
  #----------------------------------------------------------------------------
  def dispose
    @slq_window.close
    @end_window.close
    [@skinmenu, @mapname, @gold, @slq_window, @end_window, @simple_status,
    @hpbar, @mpbar, @xpbar, @pain, @arrow_pred, @arrow_next].each(&:dispose)
    @option.each(&:dispose)
  end
  #----------------------------------------------------------------------------
  # • Atualização dos objetos.
  #----------------------------------------------------------------------------
  def update
    [@end_window, @gold, @slq_window, @hpbar, @mpbar, @xpbar, @pain].each(&:update)
    [@hpbar, @mpbar, @xpbar].each { |i| i.opa 25 }
    DS::FONT_PROC[@gold.bitmap, :NORMAL]
    @gold.text = $game_party.gold.to_s
    update_option
    @arrow_pred.if_mouse_over { |over| @arrow_pred.opacity = over ? 255 : 127 }
    @arrow_pred.if_mouse_click {
      @actor_index = @actor_index <= 0 ? $game_party.members.size.pred : @actor_index.pred
      define_simple_status
    }
    @arrow_next.if_mouse_over { |over| @arrow_next.opacity = over ? 255 : 127 }
    @arrow_next.if_mouse_click {
      @actor_index = @actor_index >= $game_party.members.size.pred ? 0 : @actor_index.next
      define_simple_status
    }
  end
  #----------------------------------------------------------------------------
  # • Atualizar as opções.
  #----------------------------------------------------------------------------
  def update_option
    @option.each_with_index { |i, n|
      i.if_mouse_over { |over| i.opacity = over ? 255 : 127
      }
      i.if_mouse_click {
        command(n) unless DS.in_message?
      }
    }
  end
  #----------------------------------------------------------------------------
  # • Comandos.
  #----------------------------------------------------------------------------
  def command(n)
    cmd = OPTION_COMMAND[n][1]
    if n == 3
      @slq_window.open
      @slq_window.active = true
      @slq_window.visible = true
      $game_player.no_movable = MENU.get(:stop_walk)
    end
    return if cmd.nil?
    SceneManager.call(eval(cmd))
  end
end
#==============================================================================
# ** Window_SLQ
#------------------------------------------------------------------------------
#  Esta janela para seleção das opções Fim do Jogo/Retornar ao Título na
# tela de fim de jogo.
#==============================================================================
class Window_SLQ < Window_Command
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0)
    update_placement
    self.openness = 0
    self.active = false
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * Aquisição da largura da janela
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição da janela
  #--------------------------------------------------------------------------
  def update_placement
    self.position 1
    self.y = (DS.height - height) / 2
    self.z = DS.z + 100
  end
  #--------------------------------------------------------------------------
  # * Criação da lista de comandos
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Salvar", :save, !$game_system.save_disabled)
    add_command("Carregar", :load)
    add_command("Sair do Jogo",   :end)
    add_command("Retornar", :cancel)
  end
end
#==============================================================================
# ** Window_GameEnd
#------------------------------------------------------------------------------
#  Esta janela para seleção das opções Fim do Jogo/Retornar ao Título na
# tela de fim de jogo.
#==============================================================================
class Window_GameEnd < Window_Command
  #--------------------------------------------------------------------------
  # * Atualização da posição da janela
  #--------------------------------------------------------------------------
  def update_placement
    self.position 1
    self.y = (DS.height - height) / 2
    self.z = DS.z + 100
  end
end
#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  Esta janela exibe explicação de habilidades e itens e outras informações.
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # * Renovação
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    self.ox = 0
    @_x = false
    @update = contents.text_size(@text.split(/\r\n/).select { |i| contents.text_size(i).width > width }).width > width
    @text.split(/\r\n/).each_with_index { |txt, n|
      draw_text(4, contents.font.size * n, contents.text_size(txt).width, contents.font.size, txt)
    }
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    return unless @update
    c_width = contents.text_size(@text.split(/\r\n/).select { |i| contents.text_size(i).width > width }).width
    unless @_x
      self.ox -= 1
      @_x = self.ox <= -(c_width - (self.width - (c_width/4)  ))
    else
      self.ox += 1
      @_x = false if self.ox >= (c_width - (c_width/1.1).round  )
    end
  end
end
#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  Esta janela exibe os parâmetros dos membros do grupo na tela de menu.
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Aquisição da largura da janela
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 32
  end
  #--------------------------------------------------------------------------
  # * Desenho de um item
  #     index : índice do item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_simple_status(actor, rect.x, rect.y + line_height / 2)
  end
end
#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  Esta janela exibe a lista de itens possuidos na tela de itens.
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Aquisição do número de colunas
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end
#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
#  Esta é a superclasse das classes que executam as telas de itens e
# habilidades.
#==============================================================================

class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  alias :dsi_item_base_start :start
  def start
    dsi_item_base_start
    $game_system.map_img.z = 0
  end
  #--------------------------------------------------------------------------
  # * Definição de cursor na coluna da esquerda
  #--------------------------------------------------------------------------
  def cursor_left?
    return 0
  end
end

#==============================================================================
# ** Scene_Item
#------------------------------------------------------------------------------
#  Esta classe executa o processamento da tela de item.
#==============================================================================

class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # * Criação da janela de itens
  #--------------------------------------------------------------------------
  def create_item_window
    wy = DS.height
    wh = DS.height
    @item_window = Window_ItemList.new(0, wy, Graphics.width, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
end
#==============================================================================
# ** Window_SkillList
#------------------------------------------------------------------------------
#  Esta janela exibe uma lista de habilidades usáveis na tela de habilidades.
#==============================================================================

class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Aquisição do número de colunas
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
end
#==============================================================================
# ** Scene_Skill
#------------------------------------------------------------------------------
#  Esta classe executa o processamento da tela de habilidades. Por conveniência
# dos processos em comum, as habilidades são tratdas como [Itens].
#==============================================================================

class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # * Criação da janela de itens
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = DS.height
    ww = Graphics.width
    wh = DS.height
    @item_window = Window_SkillList.new(wx, wy, ww, wh)
    @item_window.actor = @actor
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @command_window.skill_window = @item_window
  end
end
#==============================================================================
# ** Window_EquipStatus
#------------------------------------------------------------------------------
#  Esta janela exibe as mudanças nos parâmetros do herói na tela de
# equipamentos.
#==============================================================================

class Window_EquipStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Aquisição da largura da janela
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width
  end
end

#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  Esta classe executa o processamento da tela de equipamentos.
#==============================================================================

class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Inicialização do processo
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_command_window
    create_slot_window
    create_item_window
    create_status_window
    @slot_window.status_window = @status_window
    @item_window.status_window = @status_window
    $game_system.map_img.z = 0
  end
  #--------------------------------------------------------------------------
  # * Criação da janela de atributos
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_EquipStatus.new(0, @help_window.height)
    @status_window.viewport = @viewport
    @status_window.actor = @actor
    @status_window.visible = false
    @status_window.z
  end
  #--------------------------------------------------------------------------
  # * Criação da janela de comando
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_EquipCommand.new(0, @help_window.height, Graphics.width)
    @command_window.viewport = @viewport
    @command_window.help_window = @help_window
    @command_window.set_handler(:equip,    method(:command_equip))
    @command_window.set_handler(:optimize, method(:command_optimize))
    @command_window.set_handler(:clear,    method(:command_clear))
    @command_window.set_handler(:cancel,   method(:return_scene))
    @command_window.set_handler(:pagedown, method(:next_actor))
    @command_window.set_handler(:pageup,   method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # * Criação da janela de slots
  #--------------------------------------------------------------------------
  def create_slot_window
    @slot_window = Window_EquipSlot.new(0, @help_window.height+48, Graphics.width)
    @slot_window.viewport = @viewport
    @slot_window.help_window = @help_window
    @slot_window.actor = @actor
    @slot_window.set_handler(:ok,       method(:on_slot_ok))
    @slot_window.set_handler(:cancel,   method(:on_slot_cancel))
  end
  #--------------------------------------------------------------------------
  # * Criação da janela de item
  #--------------------------------------------------------------------------
  def create_item_window
    wx = 0
    wy = DS.height + 48
    ww = Graphics.width
    wh = DS.height - 48
    @item_window = Window_EquipItem.new(wx, wy, ww, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.actor = @actor
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @slot_window.item_window = @item_window
  end

  def update
    super
    @status_window.visible = @item_window.active
  end
end

#==============================================================================
# • Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  alias :dsi_default_menu_start :start
  alias :dsi_default_menu_terminate :terminate
  alias :dsi_default_menu_update :update
  #----------------------------------------------------------------------------
  # • Inicialização dos objetos.
  #----------------------------------------------------------------------------
  def start
    dsi_default_menu_start
    @menu = Scene_Menu.new
  end
  #----------------------------------------------------------------------------
  # • Renovação dos objetos.
  #----------------------------------------------------------------------------
  def terminate
    dsi_default_menu_terminate
    @menu.dispose
  end
  #----------------------------------------------------------------------------
  # • Atualização dos objetos.
  #----------------------------------------------------------------------------
  def update
    dsi_default_menu_update
    @menu.update
  end
  #--------------------------------------------------------------------------
  # * Atualização da chamada do menu quando pressionada tecla
  #--------------------------------------------------------------------------
  def update_call_menu
  end
  #--------------------------------------------------------------------------
  # * Chamada do menu
  #--------------------------------------------------------------------------
  def call_menu
  end
end
}
