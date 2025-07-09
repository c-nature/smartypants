extends Node

enum GameMode { ONE_PLAYER, TWO_PLAYERS }

var current_game_mode = GameMode.ONE_PLAYER # Default to 1-player
var player1_paddle_texture_path = "" # Path to Player 1's chosen paddle texture
var player2_paddle_texture_path = "" # Path to Player 2's chosen paddle texture (used in 2-player mode)
var ai_paddle_texture_path = ""      # Path to AI's chosen paddle texture (used in 1-player mode)

# Updated list of available paddle textures using full names as keys
# Added new paddle textures for selection.
var available_paddle_textures = {
	"Donald Trump": {"path": "res://Assets/Paddles/trump.png", "term": "2017-2021, 2025-present"},
	"Joe Biden": {"path": "res://Assets/Paddles/biden.png", "term": "2021-2025"},
	"Barack Obama": {"path": "res://Assets/Paddles/obama.png", "term": "2009-2017"},
	"George W. Bush": {"path": "res://Assets/Paddles/bushjunior.png", "term": "2001-2009"},
	"Bill Clinton": {"path": "res://Assets/Paddles/clinton.png", "term": "1993-2001"},
	"George H.W. Bush": {"path": "res://Assets/Paddles/bushsenior.png", "term": "1989-1993"},
	"Ronald Reagan": {"path": "res://Assets/Paddles/reagan.png", "term": "1981-1989"},
	"Jimmy Carter": {"path": "res://Assets/Paddles/jimmycarter.png", "term": "1977-1981"},
	"Gerald Ford": {"path": "res://Assets/Paddles/geraldford.png", "term": "1974-1977"},
	"Richard M. Nixon": {"path": "res://Assets/Paddles/nixon.png", "term": "1969-1974"},
	"Lyndon B. Johnson": {"path": "res://Assets/Paddles/lbjohnson.png", "term": "1963-1969"},
	"John F. Kennedy": {"path": "res://Assets/Paddles/johnfkennedy.png", "term": "1961-1963"},
	"Dwight D. Eisenhower": {"path": "res://Assets/Paddles/eisenhower.png", "term": "1953-1961"},
	"Harry S. Truman": {"path": "res://Assets/Paddles/truman.png", "term": "1945-1953"},
	"Franklin D. Roosevelt": {"path": "res://Assets/Paddles/roosevelt.png", "term": "1933-1945"},
	"Herbert Hoover": {"path": "res://Assets/Paddles/hoover.png", "term": "1929-1933"}, 
	"Calvin Coolidge": {"path": "res://Assets/Paddles/coolidge.png", "term": "1923-1929"},
	"Warren G. Harding": {"path": "res://Assets/Paddles/harding.png", "term": "1921-1923"}, 
	"Woodrow Wilson": {"path": "res://Assets/Paddles/wilson.png", "term": "1913-1921"}, 
	"William Howard Taft": {"path": "res://Assets/Paddles/taft.png", "term": "1909-1913"}, 
	"Theodore Roosevelt": {"path": "res://Assets/Paddles/roosevelt2.png", "term": "1901-1909"}, 
	"William McKinley": {"path": "res://Assets/Paddles/mckinley.png", "term": "1897-1901"},  
	"Benjamin Harrison": {"path": "res://Assets/Paddles/harrison2.png", "term": "1889-1893"},   
	"Grover Cleveland": {"path": "res://Assets/Paddles/cleveland.png", "term": "1885-1889, 1893-1897"},    
	"Chester A. Arthur": {"path": "res://Assets/Paddles/arthur.png", "term": "1881-1885"}, 
	"James A. Garfield": {"path": "res://Assets/Paddles/garfield.png", "term": "1881"}, 
	"Rutherford B. Hayes": {"path": "res://Assets/Paddles/hayes.png", "term": "1877-1881"}, 
	"Ulysses S. Grant": {"path": "res://Assets/Paddles/grant.png", "term": "1869-1877"},  
	"Andrew Johnson": {"path": "res://Assets/Paddles/johnson.png", "term": "1865-1869"},  
	"Abraham Lincoln": {"path": "res://Assets/Paddles/lincoln.png", "term": "1861-1865"},  
	"James Buchanan": {"path": "res://Assets/Paddles/buchanan.png", "term": "1857-1861"},  
	"Franklin Pierce": {"path": "res://Assets/Paddles/pierce.png", "term": "1853-1857"},  
	"Millard Fillmore": {"path": "res://Assets/Paddles/filmore.png", "term": "1850-1853"},  
	"Zachary Taylor": {"path": "res://Assets/Paddles/taylor.png", "term": "1849-1850"},  
	"James K. Polk": {"path": "res://Assets/Paddles/polk.png", "term": "1845-1849"},   
	"John Tyler": {"path": "res://Assets/Paddles/tyler.png", "term": "1841-1845"},  
	"William Henry Harrison": {"path": "res://Assets/Paddles/harrison.png", "term": "1841"},  
	"Martin van Buren": {"path": "res://Assets/Paddles/vanburen.png", "term": "1837-1841"},   
	"Andrew Jackson": {"path": "res://Assets/Paddles/jackson.png", "term": "1829-1837"},   
	"John Quincy Adams": {"path": "res://Assets/Paddles/quincy.png", "term": "1825-1829"},  
	"James Monroe": {"path": "res://Assets/Paddles/monroe.png", "term": "1817-1825"},  
	"James Madison": {"path": "res://Assets/Paddles/madison.png", "term": "1809-1817"},  
	"Thomas Jefferson": {"path": "res://Assets/Paddles/jefferson.png", "term": "1801-1809"}, 
	"John Adams": {"path": "res://Assets/Paddles/adams.png", "term": "1797-1801"},
	"George Washington": {"path": "res://Assets/Paddles/washington.png", "term": "1789-1797"},
}

# In GameManager.gd (add this function)
func _get_president_name_from_path(path: String) -> String:
	for president_name in available_paddle_textures:
		if available_paddle_textures[president_name]["path"] == path:
			return president_name
	return "Unknown President" # Fallback if path not found


func _ready():
	print("GameManager loaded.")
	# Removed default paddle assignments here.
	# Paddles must now be explicitly selected on the PaddleSelectScreen.
