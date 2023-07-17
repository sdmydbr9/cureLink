// custom_loader.js

// Function to create and show the custom loading animation
function showCustomLoadingAnimation() {
  const loadingDiv = document.createElement("div");
  loadingDiv.id = "custom-loading-animation";
  loadingDiv.style.display = "flex";
  loadingDiv.style.justifyContent = "center";
  loadingDiv.style.alignItems = "center";
  loadingDiv.style.height = "100vh";
  loadingDiv.style.fontSize = "24px";

  const cureLinkText = document.createElement("div");
  cureLinkText.textContent = "CureLink";
  cureLinkText.style.fontSize = "16px"; // Small initial font size
  cureLinkText.style.transition = "font-size 2s"; // Smooth transition

  // Delay the zoom-in animation to make it more visible
  setTimeout(() => {
    cureLinkText.style.fontSize = "40px"; // Larger font size after delay
  }, 1000);

  loadingDiv.appendChild(cureLinkText);
  document.body.appendChild(loadingDiv);
}

// Function to hide the custom loading animation
function hideCustomLoadingAnimation() {
  const loadingDiv = document.getElementById("custom-loading-animation");
  if (loadingDiv) {
    loadingDiv.remove();
  }
}

// Show the custom loading animation when the window is loaded
window.addEventListener("load", function (ev) {
  showCustomLoadingAnimation();

  // Download main.dart.js
  _flutter.loader.loadEntrypoint({
    serviceWorker: {
      serviceWorkerVersion: serviceWorkerVersion,
    },
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine().then(function (appRunner) {
        // Hide the custom loading animation and show the app content
        hideCustomLoadingAnimation();
        appRunner.runApp();
      });
    },
  });
});
