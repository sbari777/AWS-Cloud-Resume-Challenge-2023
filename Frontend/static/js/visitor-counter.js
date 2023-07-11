// Log a message to the console when the script is loaded
console.log('Visitor counter script loaded.');

// Assign an event listener to the window's onload event
window.onload = () => {
  // Log a message to the console when the script is executed after the page is loaded
  console.log("Script loaded and executed");

  // Call the updateVisitorCounter function
  updateVisitorCounter();
};

// Define an async function called updateVisitorCounter
async function updateVisitorCounter() {
  try {
    // Fetch the visitor count from the API at the given URL
    const response = await fetch("https://44b4qrqwj2.execute-api.us-west-2.amazonaws.com/Production/VC-API-METHODS");

    // Parse the JSON response
    const data = await response.json();

    // Extract the count property from the parsed JSON data
    const count = data.body;

    // Log the fetched visitor count to the console
    console.log("Fetched visitor count:", count);

    // Get the visitor-counter HTML element using its ID
    const visitorCounterElement = document.getElementById("visitor-counter");
    // Log the visitor-counter element to the console
    console.log("Visitor counter element:", visitorCounterElement);

    // Update the text content of the visitor-counter element with the fetched count
    visitorCounterElement.textContent = count;
  } catch (error) {
    // Log any errors that occur during the fetch or JSON parsing process
    console.error("Error fetching visitor count:", error);
  }
}
