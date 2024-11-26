math.randomseed(os.time()) --seeds the random number generator with the current time to ensure randomness

local level = 1
local maxlevel = 5
local score = 0

print("------------ WELCOME TO THE GUESS THE NUMBER GAME!-----------")
print("Advance through the game by guessing the number I'm thinking of.")

while level <=maxlevel do
    print("-----------------------------------------------------------")
    print("\nLEVEL " .. level)
    print("-----------------------------------------------------------\n")
    local range = level*100
    secret_no = math.random(1, range)
    local max_attempts = 8 - level
    local attempts = 0
    local guess_correctly = false

    print("I'm thinking of a number between 1 and " .. range .. ". Can you guess it?")

    while guess_correctly == false and attempts < max_attempts do
        print("You have " .. (max_attempts - attempts) .. " attempts left.")
        print("Enter your guess: ")
        local guess = io.read("*n")
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        attempts = attempts + 1

        if guess == secret_no then
            print("Congratulations! You guessed the number in " .. attempts .. " attempts.")
            guess_correctly = true
            score = score + (max_attempts - attempts + 1) * 10 -- Add bonus for remaining attempts

        elseif guess < secret_no then
            print("Too low. Try again.")

        else
            print("Too high. Try again.")
        end
    end

    if guess_correctly then 
        print("Great job! You've completed level " .. level .. " with a score of " .. score)
        level = level + 1
    end

    if not guess_correctly then
        print("Sorry, you have exhausted all your attempts. The number was " .. secret_no)
        print("Game over! Your total score is: " .. score)
        break
    end

        
end

if level > maxlevel then 
    print("Congratulations! You've completed all levels with a final score of " .. score)
end