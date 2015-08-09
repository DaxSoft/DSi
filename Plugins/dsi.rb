#==============================================================================
# • DSi Core
#==============================================================================
# Autor: Dax
# Versão: &beta
# Site: www.dax-soft.weebly.com
# Requerimento: Dax Core
#==============================================================================
# • Descrição:
#------------------------------------------------------------------------------
#  Sistema que faz com que o jogo criado no rpg maker vire um pseudo-jogo de
# nitendo DS.
#==============================================================================
# • Versões:
#------------------------------------------------------------------------------
# &beta :
#  - Módulo inicial.
#  - Mouse Integrado.
#  - Mapa configurado.
#  - Tela de título.
#  - Menu.
#  - Sistema de Mensagem.
#==============================================================================
Dax.register(:dsi, "dax", 0.5) do
  #============================================================================
  # • Configuração da fonte. Caso não queira esta configuração. Delete.
  #============================================================================
  Font.default_name = "Trebuchet MS"
  Font.default_size = 18
  Font.default_bold = false
  Font.default_italic = false
  Font.default_outline = false
  Font.default_shadow = true
  Font.default_color = Color.new.default
  #----------------------------------------------------------------------------
  # • Carregar os scripts. Insira aqui, caso tenha add-ons.
  #----------------------------------------------------------------------------
  load_script($ROOT_PATH["mouse_window_selectable.rb"])
  load_script($ROOT_PATH["dsi_module.rb", "DSi/"])
  load_script($ROOT_PATH["dsi_message.rb", "DSi/"])
  load_script($ROOT_PATH["dsi_menu.rb", "DSi/"])
  #--------------------------------------------------------------------------
  # • Redimensionar tela.
  #--------------------------------------------------------------------------
  Graphics.resize_screen(DS.screen_width, DS.screen_height)
end
