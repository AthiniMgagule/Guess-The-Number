local lineY = 300
local buttons = {}
local message = ""
local guessedNumbers = ""
local secretNumber = nil
local highScore = 0
local score = 0
local maxAttempts = 0
local attempts = 0
local game_state = "start"
local level = 1
local maxLevel = 5

local header = 50
local menuOpen = false
local menuButton = {x = 750, y = 10 , width = 30, height = 30}
local menuItems = {
    {text = "New Game", action = function() print("New Game") end},
    {text = "Resume", action = function() print("Resume") end},
    {text = "Settings", action = function() print("Options") end},
    {text = "Exit", action = function() love.event.quit() end}
}

-- love.load is called once at the beginning
function love.load()
    love.window.setTitle("Guess the Number")
    love.graphics.setBackgroundColor(138/255, 43/255, 226/255) -- Purple violet background

     -- Load bold font for title
     boldFont = love.graphics.newFont("fonts/HaloDek.ttf", 48)

    -- Fonts for title text
    fonts = {
        love.graphics.newFont("fonts/HaloDek.ttf", 60),
        love.graphics.newFont("fonts/HaloDek.ttf", 50),
        love.graphics.newFont("fonts/HaloDek.ttf", 40),
        love.graphics.newFont("fonts/HaloDek.ttf", 30),
    }

    -- Play button attributes
    button = {
        x = 300,
        y = 400,
        width = 200,
        height = 50,
        text = "Play"
    }

    question_marks = {} -- For random question marks around the button
    for i = 1, 20 do
        table.insert(question_marks, {
            x = love.math.random(0, 800),
            y = love.math.random(0, 600),
            size = love.math.random(12, 36)
        })
    end

     -- Random numbers around the screen
     random_numbers = {}
     for i = 1, 20 do
         table.insert(random_numbers, {
             x = love.math.random(0, 800),
             y = love.math.random(0, 600),
             size = love.math.random(12, 24),
             number = love.math.random(0, 9)
         })
     end

      -- Create buttons for 0-9
    for i = 0, 9 do
        table.insert(buttons, {x = 80 + (i % 5) * 80, y = lineY + 50, number = i})
    end

     -- Create buttons for 0-9
     local buttonSpacing = 80 -- Horizontal spacing between buttons
     local buttonSize = 60 -- Size of each button
     local rowSpacing = 20 -- Vertical space between all rows
     local buttonVerticalOffset = lineY + 50 -- Starting Y position for buttons
 
     -- Create the buttons with updated positions
     for i = 0, 9 do
         -- Calculate X position
         local xPos = 80 + (i % 5) * buttonSpacing
 
         -- Calculate Y position with consistent spacing between all rows
         local yPos = buttonVerticalOffset + math.floor(i / 5) * (buttonSize + rowSpacing)
         
         -- Insert the button into the buttons table
         table.insert(buttons, {x = xPos, y = yPos, number = i})
     end

     love.keyboard.setTextInput(true)  -- Enable text input for guessing

    -- Game state
    game_state = "start" -- 'start' for start screen, 'play' for the game itself
end

-- Draw game screen with additional game logic displayed
function love.draw()
    if game_state == "start" then
        drawStartScreen()
    elseif game_state == "play" then
        drawGameScreen()
        if gameOver then
            love.graphics.setFont(fonts[4])
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("Game Over! Final Score: " .. score, love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2)
        end
    end
end

-- Function to draw the start screen
function drawStartScreen()
    local title = {"Guess", "The", "Number"}

    -- Draw the title at the center of the screen
    local centerX = love.graphics.getWidth() / 2
    local startY = 100
    for i, text in ipairs(title) do
        love.graphics.setFont(fonts[i])
        local textWidth = fonts[i]:getWidth(text)
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.print(text, centerX - textWidth / 2, startY)
        startY = startY + fonts[i]:getHeight() + 5
    end

    -- Draw the Play button
    love.graphics.setColor(0, 1, 0) -- Green button
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    love.graphics.setColor(0, 0, 0) -- Black text
    love.graphics.setFont(fonts[4])
    love.graphics.print(button.text, button.x + button.width / 2 - fonts[4]:getWidth(button.text) / 2, button.y + button.height / 2 - fonts[4]:getHeight(button.text) / 2)

    -- Draw question marks around the button
    love.graphics.setColor(1, 1, 0) -- Yellow question marks
    for _, q in ipairs(question_marks) do
        love.graphics.setFont(love.graphics.newFont(q.size))
        love.graphics.print("?", q.x, q.y)
    end

    -- Draw random numbers
    love.graphics.setColor(0, 1, 1) -- Cyan numbers
    for _, num in ipairs(random_numbers) do
        love.graphics.setFont(love.graphics.newFont(num.size))
        love.graphics.print(tostring(num.number), num.x, num.y)
    end
end

-- Function to draw the game screen (placeholder for now)
function drawGameScreen()
    --draw  header
    love.graphics.setColor(0.2, 0.2, 0.2) --dark grey
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), header)

    --draw textbox
    drawTextboxAndButton()

    -- Draw game info (level, score)
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.print("Level: " .. level, 10, 15)
    love.graphics.print("Score: " .. score, love.graphics.getWidth() - 150, 15)
    love.graphics.print("Attempts: " .. attempts .. "/" .. maxAttempts, love.graphics.getWidth() / 2 - 100, 15)


    --draw level info
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.print("Level: " ..level, 10, 15)

    -- draw hamburger menu
    love.graphics.setColor(1, 1, 1) -- White text
    for i = 0,2 do
        love.graphics.rectangle("fill", menuButton.x, menuButton.y + i * 8, menuButton.width, 4)
    end

    if menuOpen then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9) -- Semi-transparent black
        love.graphics.rectangle("fill", 0, header, 200, #menuItems * 30)
    
        -- Draw menu items
        love.graphics.setColor(1, 1, 1) -- White text
        for i, item in ipairs(menuItems) do
            love.graphics.print(item.text, 10, header + (i - 1) * 30 + 5)
        end
    end    

    -- Draw the line with a question mark at the center
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(love.graphics.getWidth() / 2 - 200, lineY, love.graphics.getWidth() / 2 + 200, lineY)
    love.graphics.print("?", love.graphics.getWidth() / 2 - 8, lineY - 25)

    -- Draw number buttons
    for _, button in ipairs(buttons) do
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.circle("fill", button.x, button.y, 30)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(button.number, button.x - 8, button.y - 10)
    end

    -- Draw score and high score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, love.graphics.getWidth() - 150, lineY + 50)
    love.graphics.print("High Score: " .. highScore, love.graphics.getWidth() - 150, lineY + 80)

end

-- love.mousepressed handles mouse click events
function love.mousepressed(x, y, buttonType, isTouch)
    if game_state == "start" and buttonType == 1 then -- Left mouse button
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            startNewGame()
            game_state = "play" -- Switch to play state
        end
    elseif game_state == "play" and buttonType == 1 then -- Left mouse button
        if x >= menuButton.x and x <= menuButton.x + menuButton.width and y >= menuButton.y and y <= menuButton.y + menuButton.height then
            menuOpen = not menuOpen -- toggle menu
        end

        if menuOpen then
            for i, item in ipairs(menuItems) do
                local itemY = header + (i - 1) * 30
                if x >= 100 and x < 300 and y >itemY and y < itemY + 30 then
                    handleMenuSelection(item)
                    menuOpen = false
                end
            end
        end

        --check if a number button was clicked
        for _, button in ipairs(buttons) do
            local dist = math.sqrt((x - button.x)^2 + (y - button.y)^2)
            if dist <= 30 then
                guessedNumbers = guessedNumbers .. toString(button.number)
                checkGuess()
                break
            end
        end
    end
end

-- Function to handle menu item selection
function handleMenuSelection(item)
    if item.text == "New Game" then
        level = 1
        print("Starting New Game...")
    elseif item.text == "Resume" then
        print("Resuming Game...")
    elseif item.text == "Settings" then
        print("Opening Settings...")
    elseif item.text == "Exit" then
        love.event.quit()
    end
end

function drawTextboxAndButton()
    -- Textbox position and size
    local textboxWidth = 400
    local textboxHeight = 50
    local textboxX = (love.graphics.getWidth() - textboxWidth) / 2  -- Centered horizontally
    local textboxY = lineY - textboxHeight - 40  -- Positioned above the line

    -- Draw the white border (outline) of the textbox
    love.graphics.setColor(1, 1, 1)  -- White color for the border
    love.graphics.rectangle("line", textboxX, textboxY, textboxWidth, textboxHeight, 20)  -- Rounded edges with radius 20

    -- Draw the white background of the textbox
    love.graphics.setColor(1, 1, 1)  -- White color for the background
    love.graphics.rectangle("fill", textboxX, textboxY, textboxWidth, textboxHeight, 20)  -- Rounded edges with radius 20

    -- Draw some placeholder text inside the textbox (just for demonstration)
    love.graphics.setColor(0, 0, 0)  -- Black color for text
    love.graphics.setFont(fonts[4])  -- Use the appropriate font
    love.graphics.print("Enter your guess", textboxX + 10, textboxY + 10)  -- Slight padding from the border

    -- Position for the round button next to the textbox
    local buttonRadius = textboxHeight / 2  -- Same height as the textbox, making it a circle
    local buttonX = textboxX + textboxWidth + 20  -- Position the button to the right of the textbox
    local buttonY = textboxY + buttonRadius  -- Vertically center the button with the textbox

    -- Draw the round button (circle)
    love.graphics.setColor(0, 1, 0)  -- Green color for the button (you can change this)
    love.graphics.circle("fill", buttonX, buttonY, buttonRadius)  -- Fill the circle

    -- Draw the tick mark inside the button
    love.graphics.setColor(1, 1, 1)  -- White color for the tick mark
    love.graphics.setLineWidth(5)  -- Make the tick mark thicker
    love.graphics.line(buttonX - 12, buttonY, buttonX, buttonY + 8)  -- Left part of the tick
    love.graphics.line(buttonX, buttonY + 8, buttonX + 12, buttonY - 8)  -- Right part of the tick
end

-- Function to start a new game
function startNewGame()
    -- Generate a new secret number between 1 and 100 for each level
    secretNumber = love.math.random(1, 100)
    guessedNumbers = ""
    attempts = 0
    score = 0
    gameOver = false
end

-- Function to check if the guess is correct or not
function checkGuess()
    attempts = attempts + 1
    -- Compare guessed number with secret number
    local guess = tonumber(guessedNumbers)
    
    if guess == secretNumber then
        score = score + 10 -- Award 10 points for a correct guess
        level = level + 1
        if level > maxLevel then
            gameOver = true
            print("You win! Game over!")
        else
            print("Correct! Moving to next level...")
            startNewGame()
        end
    elseif attempts >= maxAttempts then
        gameOver = true
        print("Game Over! You've run out of attempts.")
    else
        print("Incorrect guess! Try again.")
    end
end


-- math.randomseed(os.time()) --seeds the random number generator with the current time to ensure randomness

-- local level = 1
-- local maxlevel = 5
-- local score = 0

-- print("------------ WELCOME TO THE GUESS THE NUMBER GAME!-----------")
-- print("Advance through the game by guessing the number I'm thinking of.")

-- while level <=maxlevel do
--     print("-----------------------------------------------------------")
--     print("\nLEVEL " .. level)
--     print("-----------------------------------------------------------\n")
--     local range = level*100
--     secret_no = math.random(1, range)
--     local max_attempts = 8 - level
--     local attempts = 0
--     local guess_correctly = false

--     print("I'm thinking of a number between 1 and " .. range .. ". Can you guess it?")

--     while guess_correctly == false and attempts < max_attempts do
--         print("You have " .. (max_attempts - attempts) .. " attempts left.")
--         print("Enter your guess: ")
--         local guess = io.read("*n")
--         print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
--         attempts = attempts + 1

--         if guess == secret_no then
--             print("Congratulations! You guessed the number in " .. attempts .. " attempts.")
--             guess_correctly = true
--             score = score + (max_attempts - attempts + 1) * 10 -- Add bonus for remaining attempts

--         elseif guess < secret_no then
--             print("Too low. Try again.")

--         else
--             print("Too high. Try again.")
--         end
--     end

--     if guess_correctly then 
--         print("Great job! You've completed level " .. level .. " with a score of " .. score)
--         level = level + 1
--     end

--     if not guess_correctly then
--         print("Sorry, you have exhausted all your attempts. The number was " .. secret_no)
--         print("Game over! Your total score is: " .. score)
--         break
--     end      
-- end

-- if level > maxlevel then 
--     print("Congratulations! You've completed all levels with a final score of " .. score)
-- end