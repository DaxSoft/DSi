#==============================================================================
# • DSi Default Message
#==============================================================================
# Autor: Dax
# Versão: 1.0
# Site: www.dax-soft.weebly.com
# Requerimento: Dax Core
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Sistema de mensagem padrão.
#==============================================================================
# • Versões:
#------------------------------------------------------------------------------
# 1.0 :
#   - Comandos básicos.
#==============================================================================
Dax.register(:dsi_default_mesage, "dax", 1.0, [[:dsi_module, "dax"]]) {
#==============================================================================
# • Window_Message
#==============================================================================
class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * Inicialização do objeto
  #--------------------------------------------------------------------------
  alias :dsi_msg_init :initialize
  def initialize(*args)
    dsi_msg_init
    unless DS::MSGBOX.empty?
      @background_msgbox = Sprite.new("S: #{DS::MSGBOX}")
      @background_msgbox.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # * Aquisição do número de linhas exibidas
  #--------------------------------------------------------------------------
  def visible_line_number
    return DS::VLN_MS
  end
  #--------------------------------------------------------------------------
  # * Disposição
  #--------------------------------------------------------------------------
  alias :dsi_msg_dispose :dispose
  def dispose
    dsi_msg_dispose
    @background_msgbox.dispose unless DS::MSGBOX.empty?
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  alias :dsi_msg_update :update
  def update
    dsi_msg_update
    unless DS::MSGBOX.empty?
      @background_msgbox.x, @background_msgbox.y, @background_msgbox.z = self.x, self.y, self.z-1
      self.opacity = 0
      @background_msgbox.visible = $game_message.visible
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização da posição da janela
  #--------------------------------------------------------------------------
  def update_placement
    self.z = DS.z
    @position = $game_message.position
    self.y = @position * (DS.height - height) / 2
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
  end
  #--------------------------------------------------------------------------
  # * Execução de espera de entrada
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C) || trigger?(0x02) || trigger?(0x01)
    Input.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # * Definição de quebra de página
  #     text : texto
  #     pos  : posição
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    contents.clear
    draw_face($game_message.face_name, $game_message.face_index, 0, 0, true, 32, 96)
    reset_font_settings
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
    clear_flags
  end
  #--------------------------------------------------------------------------
  # * Definição de quebra de linha
  #--------------------------------------------------------------------------
  def new_line_x
    $game_message.face_name.empty? ? 0 : 32 + 16
  end
end
}
