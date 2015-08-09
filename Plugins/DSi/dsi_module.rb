#==============================================================================
# • Módulo de configuração do DSi.
#==============================================================================
Dax.register(:dsi_module, "dax", 0.5, [[:dsi, "dax", 0.5]]) {
  #===========================================================================
  # • DS : module
  #===========================================================================
  module DS
    #--------------------------------------------------------------------------
    # • Extend/Include.
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # • Configuração das variáveis.
    #--------------------------------------------------------------------------
    VLN_MS = 2 # Número de linhas visíveis na caixa de mensagem.
    DefaultMapMenu = "Grassland" # Imagem padrão.. para o map menu
    # Imagem de fundo padrão da mensangem.. Deve estar na pasta System.
    # Caso não queire.. deixe vázio: assim: ""
    MSGBOX = ""#"msgbox"
    #--------------------------------------------------------------------------
    # • Configuração das fonte.
    #--------------------------------------------------------------------------
    FONT = {
      # Fonte normal.
      NORMAL: {
        NAME: "Futura MdCn BT",
        SIZE: 12,
        BOLD: false,
        ITALIC: false,
        OUTLINE: false,
        COLOR: "FFFFFF",
        OUTCOLOR: "000000",
        SHADOW: false
      },
      # Fonte sub-normal.
      SUBNORMAL: {
        NAME: "Futura MdCn BT",
        SIZE: 10,
        BOLD: false,
        ITALIC: false,
        OUTLINE: false,
        COLOR: "FFFFFF",
        OUTCOLOR: "000000",
        SHADOW: false
      }
    }
    #--------------------------------------------------------------------------
    # • Acessar a prioridade do background.
    #--------------------------------------------------------------------------
    def z
      return 9999
    end
    #--------------------------------------------------------------------------
    # • Valor da largura da tela.
    #--------------------------------------------------------------------------
    def screen_width
      return 284
    end
    #--------------------------------------------------------------------------
    # • Valor da altura da tela.
    #--------------------------------------------------------------------------
    def screen_height
      return 432
    end
    #--------------------------------------------------------------------------
    # • Valor da altura da tela do mapa.
    #--------------------------------------------------------------------------
    def height
      return 216
    end
    #--------------------------------------------------------------------------
    # • Proc de Fonte no bitmap.
    #--------------------------------------------------------------------------
    FONT_PROC = ->(bitmap, sym) {
      return if bitmap.nil?
			bitmap = bitmap.is_a?(Bitmap) ? bitmap : bitmap.bitmap
      bitmap.font.name = FONT[sym].get(:NAME) || "Arial"
      bitmap.font.size = FONT[sym].get(:SIZE) || 24
      bitmap.font.bold = FONT[sym].get(:BOLD) || false
      bitmap.font.italic = FONT[sym].get(:ITALIC) || false
      bitmap.font.shadow = FONT[sym].get(:SHADOW) || false
      bitmap.font.outline = FONT[sym].get(:OUTLINE) || false
      bitmap.font.out_color = FONT[sym].get(:OUTCOLOR).color || Color.new.hex("000000")
      bitmap.font.color = FONT[sym].get(:COLOR).color || Color.new.default
    }
    #--------------------------------------------------------------------------
    # * Verificar se não está em modo conversa.
    #--------------------------------------------------------------------------
    def in_message?
      $game_message.busy? && $game_message.visible
    end
  end
  #===========================================================================
  # • Graphics.
  #===========================================================================
  class << Graphics
    #--------------------------------------------------------------------------
    # • Alterar o valor do width.
    #--------------------------------------------------------------------------
    def width
      return DS.screen_width
    end
    #--------------------------------------------------------------------------
    # • Alterar o valor da height.
    #--------------------------------------------------------------------------
    def height
      return DS.screen_height
    end
  end
  #===========================================================================
  # • Bitmap
  #===========================================================================
  class Bitmap
    #--------------------------------------------------------------------------
    # * Desenho do gráfico de rosto
    #--------------------------------------------------------------------------
    def draw_face(face_name, face_index, x, y, enabled = true, w=96, h=96)
      bitmap = Cache.face(face_name)
      j = (96 - w) / 2 rescue 0
      rect = Rect.new(face_index % 4 * (96 + j), face_index / 4 * 96, w, h)
      self.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
      bitmap.dispose
    end
    #--------------------------------------------------------------------------
    # * Desenho do gráfico de face do herói
    #--------------------------------------------------------------------------
    def draw_actor_face(actor, x, y, enabled = true, w=96, h=96)
      draw_face(actor.face_name, actor.face_index, x, y, enabled, w, h)
    end
  end
  #===========================================================================
  # • Game_System
  #===========================================================================
  class Game_System
    alias :dsi_init :initialize
    #--------------------------------------------------------------------------
    # * Variáveis públicas
    #--------------------------------------------------------------------------
    attr_accessor :default_background       # Imagem padrão do mapa.
    attr_accessor :map_img
    #--------------------------------------------------------------------------
    # * Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize
      dsi_init
      @map_img = nil
      @default_background = nil
    end
  end
  #===========================================================================
  # • Game_Map
  #===========================================================================
  class Game_Map
    #--------------------------------------------------------------------------
    # • Variável do mapa.
    #--------------------------------------------------------------------------
    def map
      return @map
    end
    #--------------------------------------------------------------------------
    # * Altura do mapa
    #--------------------------------------------------------------------------
    def height
      @map.height - 1
    end
    #--------------------------------------------------------------------------
    # * Aquisição do números de tiles verticais na tela
    #--------------------------------------------------------------------------
    def screen_tile_y
      DS.height / 32
    end
    #--------------------------------------------------------------------------
    # • Definição de coordenada válida
    #--------------------------------------------------------------------------
    def valid?(x, y)
      x >= 0 && x < width && y >= 0 && y < (height + 1)
    end
  end
  #===========================================================================
  # • Game_Player
  #===========================================================================
  class Game_Player < Game_Character
    #--------------------------------------------------------------------------
    # * Variáveis públicas
    #--------------------------------------------------------------------------
    attr_accessor :no_movable
    #--------------------------------------------------------------------------
    # * Inicialização do objeto
    #--------------------------------------------------------------------------
    alias :dsi_init :initialize
    def initialize(*args)
      dsi_init(*args)
      @no_movable = false
    end
    #--------------------------------------------------------------------------
    # • Coordenada X do centro da tela
    #--------------------------------------------------------------------------
    def center_x
      (Graphics.width / 32 - 1) / 1.75
    end
    #--------------------------------------------------------------------------
    # • Coordenada Y do centro da tela
    #--------------------------------------------------------------------------
    def center_y
      (DS.height / 32 - 1) / 1.75
    end
    #--------------------------------------------------------------------------
    # * Definição de mobilidade
    #--------------------------------------------------------------------------
    alias :dsi_movable? :movable?
    def movable?
      return    false if @no_movable
      dsi_movable?
    end
  end
  #===========================================================================
  # ** Sprite_Default_Map_Img
  #----------------------------------------------------------------------------
  #  Imagem padrão que ficará no quadro de baixo das cenas.
  #===========================================================================
  class Sprite_Default_Map_Img < Sprite
    #--------------------------------------------------------------------------
    # • Inicialização dos objetos.
    #--------------------------------------------------------------------------
    def initialize
      super([284, 216, 0, 216, DS.z])
      @old_background = $game_system.default_background
      unless $game_system.default_background.nil? or $game_system.default_background == ""
        self.bitmap = Cache.system($game_system.default_background)
      else
        self.bitmap.fill_rect(self.rect, "000000".color)
      end
      self.position(1)
    end
    #--------------------------------------------------------------------------
    # • Renovação dos objetos.
    #--------------------------------------------------------------------------
    def dispose
      self.bitmap.dispose
      super
    end
    #--------------------------------------------------------------------------
    # • Atualização dos objetos.
    #--------------------------------------------------------------------------
    def update
      unless @old_background == $game_system.default_background
        unless $game_system.default_background.nil? or $game_system.default_background == ""
          self.bitmap = Cache.system($game_system.default_background)
        else
          self.bitmap = Bitmap.new(284, 216)
          self.bitmap.fill_rect(self.rect, "000000".color)
        end
        @old_background = $game_system.default_background
      end
    end
  end
  #===========================================================================
  # • Window_Base
  #===========================================================================
  class Window_Base < Window
    #--------------------------------------------------------------------------
    # * Desenho do gráfico de rosto
    #     face_name  : nome do gráfico de face
    #     face_index : índice do gráfico de face
    #     x          : coordenada X
    #     y          : coordenada Y
    #     enabled    : habilitar flag, translucido quando false
    #--------------------------------------------------------------------------
    def draw_face(face_name, face_index, x, y, enabled = true, w=96, h=96)
      bitmap = Cache.face(face_name)
      j = (96 - w) / 2 rescue 0
      rect = Rect.new(face_index % 4 * (96 + j), face_index / 4 * 96, w, h)
      contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
      bitmap.dispose
    end
    #--------------------------------------------------------------------------
    # * Desenho do gráfico de face do herói
    #     actor   : herói
    #     x       : coordenada X
    #     y       : coordenada Y
    #     enabled : habilitar flag, translucido quando false
    #--------------------------------------------------------------------------
    def draw_actor_face(actor, x, y, enabled = true, w=96, h=96)
      draw_face(actor.face_name, actor.face_index, x, y, enabled, w, h)
    end
    #--------------------------------------------------------------------------
    # • Cores.
    #--------------------------------------------------------------------------
    def exp_gauge_color1;   text_color(21);  end;
    def exp_gauge_color2;   text_color(17);  end;
    #--------------------------------------------------------------------------
    # • Desenho do EXP
    #     actor  : herói
    #     x      : coordenada X
    #     y      : coordenada Y
    #     width  : largura
    #--------------------------------------------------------------------------
    def draw_actor_exp(actor, x, y, width = 115)
      draw_gauge(x, y, width, actor.exp.to_f / actor.next_level_exp.to_f, exp_gauge_color1, exp_gauge_color2)
      change_color(system_color)
      draw_text(x, y, 30, line_height,"EXP:")
      draw_current_and_max_values(x, y, width, actor.exp, actor.next_level_exp,
      normal_color, normal_color)
    end
    #--------------------------------------------------------------------------
    # * Desenho dos atributos básicos
    #     actor : herói
    #     x     : coordenada X
    #     y     : coordenada Y
    #--------------------------------------------------------------------------
    def draw_actor_simple_status(actor, x, y)
      draw_actor_name(actor, x, y)
      draw_actor_level(actor, x, y + line_height * 1)
      draw_actor_icons(actor, x, y + line_height * 2)
      draw_actor_class(actor, x + 120, y)
      draw_actor_hp(actor, x + 120, y + line_height * 1, 64)
      draw_actor_mp(actor, x + 120, y + line_height * 2, 64)
    end
  end
  #===========================================================================
  # • Window_Command
  #===========================================================================
  class Window_Command < Window_Selectable
    #--------------------------------------------------------------------------
    # * Inicialização do objeto
    #--------------------------------------------------------------------------
    def initialize(x, y, width=nil, line=nil)
      clear_command_list
      make_command_list
      super(x, y, width || window_width, line.nil? ? window_height : fitting_height(line))
      refresh
      select(0)
      activate
    end
  end
  #===========================================================================
  # • Scene_Base
  #===========================================================================
  class Scene_Base
    #--------------------------------------------------------------------------
    # • Alias : list.
    #--------------------------------------------------------------------------
    alias :dsi_start :start
    alias :dsi_update :update
    alias :dsi_terminate :terminate
    #--------------------------------------------------------------------------
    # * Inicialização do processo
    #--------------------------------------------------------------------------
    def start
      dsi_start
      $game_system.map_img = Sprite_Default_Map_Img.new
    end
    #--------------------------------------------------------------------------
    # * Atualização da tela
    #--------------------------------------------------------------------------
    def update
      dsi_update
      $game_system.map_img.update rescue nil
    end
    #--------------------------------------------------------------------------
    # * Finalização do processo
    #--------------------------------------------------------------------------
    def terminate
      dsi_terminate
      $game_system.map_img.dispose rescue nil
    end
  end
  #===========================================================================
  # • Scene_Title
  #===========================================================================
  class Scene_Title < Scene_Base
    #--------------------------------------------------------------------------
    # • Alias : list.
    #--------------------------------------------------------------------------
    alias :dsi_start2 :start
    #--------------------------------------------------------------------------
    # * Inicialização do processo
    #--------------------------------------------------------------------------
    def start
      dsi_start2
      @sprite1.z = @sprite2.z = DS.z
      @foreground_sprite.z = DS.z + 1
      @command_window.z = DS.z + 1
    end
  end
  #===========================================================================
  # • Scene_Map
  #===========================================================================
  class Scene_Map < Scene_Base
    alias :dsi_start3 :start
    #--------------------------------------------------------------------------
    # * Inicialização do processo
    #--------------------------------------------------------------------------
    def start
      $game_system.default_background ||= DS::DefaultMapMenu
      dsi_start3
    end
  end
  #===========================================================================
  # • Scene_MenuBase
  #===========================================================================
  class Scene_MenuBase < Scene_Base
    #--------------------------------------------------------------------------
    # * Criação do plano de fundo
    #--------------------------------------------------------------------------
    def create_background
      @background_sprite = Sprite.new
      @background_sprite.bitmap = SceneManager.background_bitmap
      @background_sprite.color.set(0, 0, 0, 0)
    end
  end
  #===========================================================================
  # • Sprite_Picture
  #===========================================================================
  class Sprite_Picture < Sprite
    #--------------------------------------------------------------------------
    # • Atualização dos objetos.
    #--------------------------------------------------------------------------
    def update
      super
      unless @picture.name == ""
        update_bitmap
        update_origin
        update_position
        update_zoom
        update_other
      else
        self.bitmap.dispose unless self.bitmap.nil?
      end
    end
  end

}
