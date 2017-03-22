class GosuWrapper
  class GridHelpers

    def self.div_windo_into
      Proc.new do |num_cols:, num_rows:, margin:|
        call_helper :div_section_into, {
          start_x: 0,
          start_y: 0,
          end_x: get_window_width,
          end_y: get_window_height,
          margin: margin,
          num_rows: num_rows,
          num_cols: num_cols
        }
      end
    end

    def self.div_section_into
      Proc.new do |
        start_x:, start_y:, end_x:, end_y:, num_cols:, num_rows:, margin:
      |
        total_height = end_y - start_y
        total_width = end_x - start_x
        row_height = total_height / num_rows
        col_width = total_width / num_cols
        (num_rows).times.reduce({}) do |rows, row_idx|
          row_start_y = (row_height * row_idx)
          row_end_y = (row_start_y + row_height)
          rows[row_idx] = {
            start_y: row_start_y,
            end_y: row_end_y,
            start_x: start_x,
            end_x: end_x,
            cols: (num_cols).times.reduce({}) do |cols, col_idx|
              col_start_x = col_width * col_idx
              col_end_x = col_start_x + col_width
              cols[col_idx] = {
                start_x: col_start_x + margin,
                end_x: col_end_x - margin,
                start_y: row_start_y + margin,
                end_y: row_end_y - margin,
              } 
              cols
            end
          }
          rows
        end
      end
    end

    def self.draw_grid
      Proc.new do |sections:, row_color:, col_color:|
        sections.each do |row_num, row|
          draw_rect row.merge(color: row_color)
          row[:cols].each do |col_num, col|
            draw_rect col.merge(color: col_color)
          end
        end
      end
    end
    
  end
end
