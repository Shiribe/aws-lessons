let clientId = null;
const API_URL = "https://mbo0gprxpg.execute-api.us-east-1.amazonaws.com/analyze";
// Add event listener to the uploadForm

// Remove the clientForm event listener since that form no longer exists
// and we're now handling the client ID in the uploadForm

document.addEventListener('DOMContentLoaded', function() {
  // Make sure all elements are loaded before accessing them
  const uploadForm = document.getElementById('uploadForm');
  const clientIdInput = document.getElementById('clientId');
  const imageFilesInput = document.getElementById('imageFiles');
  const resultsDiv = document.getElementById('results');
  
  if (!uploadForm || !clientIdInput || !imageFilesInput || !resultsDiv) {
    console.error('One or more required elements not found in the DOM');
    return;
  }
  
  uploadForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const clientId = clientIdInput.value.trim();
    if (!clientId) {
      alert('נא להזין מזהה לקוח');
      return;
    }

    const files = imageFilesInput.files;
    if (files.length === 0) {
      alert('נא לבחור לפחות תמונה אחת');
      return;
    }
    
    resultsDiv.innerHTML = '';

    for (const file of files) {
      const formData = new FormData();
      formData.append('clientId', clientId);
      formData.append('image', file);

      try {
        // Show loading indicator
        const loadingBox = document.createElement('div');
        loadingBox.className = 'result-box';
        loadingBox.innerHTML = `<h3>${file.name}</h3><p>מעבד תמונה...</p>`;
        resultsDiv.appendChild(loadingBox);
        
        const res = await fetch(API_URL, {
          method: 'POST',
          body: formData
        });
        
        console.log('Response status:', res.status);
        
        // Check for non-200 status codes
        if (!res.ok) {
          console.error(`HTTP error! Status: ${res.status}`);
          throw new Error(`HTTP error! Status: ${res.status}`);
        }
        
        const responseText = await res.text();
        console.log('Raw response:', responseText);
        
        // Try to parse as JSON only if it's valid
        let data;
        try {
          data = JSON.parse(responseText);
          console.log('Parsed data:', data);
        } catch (parseError) {
          console.error('JSON parse error:', parseError);
          throw new Error('Invalid response format');
        }
        
        // Check if data.labels exists before using it
        if (!data || !data.labels) {
          console.error('No labels in response:', data);
          throw new Error('No labels data received');
        }
        
        // Log labels to console
        console.log('Labels for', file.name, ':', data.labels);
        data.labels.forEach(label => {
          console.log(`- ${label.name}: ${label.confidence.toFixed(1)}%`);
        });
        
        // Remove loading indicator and show results
        resultsDiv.removeChild(loadingBox);
        const box = document.createElement('div');
        box.className = 'result-box';
        box.innerHTML = `
          <h3>${file.name}</h3>
          <ul>
            ${data.labels.map(label => `
              <li>
                <span class="label-name">${label.name}</span> -
                <span class="confidence">${label.confidence.toFixed(1)}%</span>
              </li>`).join('')}
          </ul>`;
        resultsDiv.appendChild(box);
      } catch (err) {
        console.error('Error processing image:', file.name, err);
        
        // Create a more informative error message
        const errorBox = document.createElement('div');
        errorBox.className = 'result-box error';
        errorBox.innerHTML = `
          <h3>Error processing ${file.name}</h3>
          <p>${err.message || 'An unknown error occurred'}</p>
          <p>Please try again or use a different image.</p>
        `;
        resultsDiv.appendChild(errorBox);
      }
    }
  });
});
