# colors:
WHITE = [255.chr, 255.chr, 255.chr]
BLACK = [0.chr, 0.chr, 0.chr]
GRID_WHITE = 1
GRID_BLACK = 0

# defaults:
DEFAULT_SEED = 0
DEFAULT_SIZE = 256
DEFAULT_IMG_NAME = "frac.ppm"

# directions:
UP = 0
RIGHT = 1
DOWN = 2
LEFT = 3

# ARGV[0] = size, ARGV[1] = image name (ppm), ARGV[2] = seed
$size = ARGV[0].to_i
$num_iterations = $size.to_i / 2
seed = ARGV[2].to_i
file_name = ARGV[1]

if $size == nil
  $size = DEFAULT_SIZE
end
if file_name == nil
  file_name = DEFAULT_IMG_NAME
end
if seed == nil
  seed = DEFAULT_SEED
end

srand(seed)

class Frost
  def initialize(filename, img_length)
    @output_img = open(filename, "w+")
    @output_img.puts("P6\n#{img_length} #{img_length}\n255")

    @img_grid = [] 
    @img_length = img_length
   
    img_length.times do
      row = Array.new(img_length, GRID_BLACK)
      @img_grid.push(row)
    end
    
    # start position and number of particles to be created globally
    @particle_density = 0.25
    @num_target_particles =  (img_length * img_length * @particle_density).ceil

    # particles step this many before starting new colony
    @num_diff_steps = img_length * img_length * 2
  end 

  def make_fractal
    current_num_particles = 0
    diff_steps_exceeded = true
    real_target_particles = @num_target_particles.ceil 

    real_target_particles.times do 
      find_start_pos
      @num_diff_steps.times do
        move_curr_pos 
        if neighbor_around?
          color_curr_pos
          diff_steps_exceeded = false
          break
        end 
      end 
      if diff_steps_exceeded
        color_curr_pos
        diff_steps_exceeded = true
      end
    end
  end

  def find_start_pos
    @curr_pos = [rand(@img_length), rand(@img_length)]
    while @img_grid[@curr_pos[0]][@curr_pos[1]] != GRID_BLACK
      @curr_pos = [rand(@img_length), rand(@img_length)]
    end
  end

  def color_curr_pos
    @img_grid[@curr_pos[0]][@curr_pos[1]] = GRID_WHITE
  end

  def move_curr_pos 
    dir = rand(5) 
    if dir == UP
      @curr_pos[0] = (@curr_pos[0] - 1) % @img_length
    elsif dir == RIGHT
      @curr_pos[1] = (@curr_pos[1] + 1) % @img_length
    elsif dir == DOWN
      @curr_pos[0] = (@curr_pos[0] + 1) % @img_length
    elsif dir == LEFT
      @curr_pos[1] = (@curr_pos[1] - 1) % @img_length
    end 
  end

  def neighbor_around?
    row_less_mod = (@curr_pos[0]-1) % @img_length
    col_less_mod = (@curr_pos[1]-1) % @img_length
    row_plus_mod = (@curr_pos[0]+1) % @img_length
    col_plus_mod = (@curr_pos[1]+1) % @img_length
    row_mod = @curr_pos[0] % @img_length
    col_mod = @curr_pos[1] % @img_length

    return (@img_grid[row_less_mod][col_mod] == GRID_WHITE ||
            @img_grid[row_plus_mod][col_mod] == GRID_WHITE ||
            @img_grid[row_mod][col_less_mod] == GRID_WHITE ||
            @img_grid[row_mod][col_plus_mod] == GRID_WHITE)
  end

  def print_grid
    make_fractal
    elems_array = @img_grid.flatten
    elems_array.each do |grid_color|
      if grid_color == GRID_WHITE
        @output_img.write(WHITE[0])
        @output_img.write(WHITE[1])
        @output_img.write(WHITE[2])
      else
        @output_img.write(BLACK[0])
        @output_img.write(BLACK[1])
        @output_img.write(BLACK[2])
      end
    end 
  end 

  def write_fractal
    @output_img
  end
end

fractal = Frost.new(file_name, $size)
fractal.print_grid
