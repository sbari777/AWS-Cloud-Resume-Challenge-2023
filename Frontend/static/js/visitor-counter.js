// Assign event listener to window's onload
window.onload = () => {
  // Debug Output
  console.log("Script loaded and executed");

  // Call updateVisitorCounter function
  updateVisitorCounter();
};

// updateVisitorCounter async function
async function updateVisitorCounter() {
  try {
    // Fetch visitor count from API
    const response = await fetch("https://udp3dc8t4a.execute-api.us-west-2.amazonaws.com/Production/VC-API-METHODS/");

    // Parse JSON response
    const data = await response.json();

    // Extract count property from JSON
    const count = data.body;

    // Access visitor-counter HTML element using its ID
    const visitorCounterElement = document.getElementById("visitor-counter");

    // Updates visitor-counter text with fetched count
    visitorCounterElement.textContent = count;
  } catch (error) {
    // Logs errors occuring during fetching or JSON parsing process
    console.error("Error fetching visitor count:", error);
  }
}
