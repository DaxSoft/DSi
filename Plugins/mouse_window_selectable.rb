#==============================================================================
# • Window_Selectable
#==============================================================================
Dax.register(:mouse_window_selectable, "dax", 1.0, [[:mouse, "dax"]]) {
class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Definição de controle de confirmação e cancelamento
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_ok       if ok_enabled?  && (trigger?(:C) or trigger?(0x01))
    return process_cancel   if cancel_enabled? && (trigger?(:B) or trigger?(0x02))
    return process_pagedown if handle?(:pagedown) && Input.trigger?(:R)
    return process_pageup   if handle?(:pageup)   && Input.trigger?(:L)
  end
  #--------------------------------------------------------------------------
  # * Atualização da tela
  #--------------------------------------------------------------------------
  alias :dsi_mouse_update :update
  def update
    dsi_mouse_update
    process_mouse_handling if self.active && self.open
  end
  #--------------------------------------------------------------------------
  # * Configuração do processo de movimento do Mouse.
  #--------------------------------------------------------------------------
  def process_mouse_handling
    @delay = @delay ? @delay + 1 : 0
    return if @delay % 3 > 0
    mx, my = Mouse.x, Mouse.y
    vx = self.viewport ? self.x - self.viewport.ox + self.viewport.rect.x : self.x
    vy = self.viewport ? self.y - self.viewport.oy + self.viewport.rect.y : self.y
    if mx.between?(vx, vx + self.width) && my.between?(vy, vy + self.height)
      mx -= vx + padding
      my -= vy + padding
      my += oy
      (0...item_max).each { |i|
        rect = item_rect(i)
        next unless mx.between?(rect.x, rect.x + rect.width) && my.between?(rect.y, rect.y + rect.height)
        last_index = @index
        select(i)
        Sound.play_cursor unless @index == last_index
        break
      }
    end
  end
end
}
