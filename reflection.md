# reflection.md

## Overall Learnings
One new feature I added to my Final Project, an expansion of my Project 1, was a link to a recipe for the respective potato dish. The AI-generated code did not include the link as part of the list item detailed view, rather it was hard-coded. Using what I know about variables and following the pattern of the existing code, I added a new “link” variable for the Dish struct and inserted working links into each instance, and updated the code in the DishDetailView - this helped me better understand how to call variables, especially when using lists, after declaring them.

In this project, I added a start screen - I created a new SwiftUI view and added my content, linking the button to my ContentView. By practicing with navigating between views in Swift, I got good practice on the concept, which is beneficial for future projects involving more complex, multi-view apps.

## Challenges
I saw that my initial generated code had a good amount of errors, particularly the variables for the DishStore class. I could not figure out what I was doing wrong, but when I checked the “Initializer ‘init(wrappedValue:)’ is not available…” message for one of the errors, I saw that it was telling me to import the Combine framework to fix the error. I scrolled back up top and saw that ChatGPT imported Foundation instead of Combine. By swapping Foundation for Combine, I was able to fix the errors associated with the DishStore variables, and I was able to gain a better understanding of how frameworks in Swift projects worked, e.g. that Published variables only work with the Combine framework.

## Next Steps
Ideally, in my Final Project, there would be user accounts, so for my next step, I would like to explore how that worked for a more community-based app.
