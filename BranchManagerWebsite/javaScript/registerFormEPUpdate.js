import { initializeApp } from "https://www.gstatic.com/firebasejs/10.4.0/firebase-app.js";
import { getFirestore, doc, updateDoc, query, where, getDoc, getDocs, collection } from 'https://www.gstatic.com/firebasejs/10.4.0/firebase-firestore.js';

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyAWSHSS6v0pG5VxrmfXElArcMpjBT5o6hg",
    authDomain: "app-be149.firebaseapp.com",
    projectId: "app-be149",
    storageBucket: "app-be149.appspot.com",
    messagingSenderId: "18569998394",
    appId: "1:18569998394:web:c8efa4c8b656702c1cc503"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Access Firestore
const db = getFirestore(app);

// Specify the correct name of the collection for employees
const employeeCollectionName = "Station_Employee";

document.addEventListener("DOMContentLoaded", async function () {
    var count = 0;
    let hash_new_password; 
    // Retrieve query parameters from the URL
    const urlParams = new URLSearchParams(window.location.search);

    // Get values from query parameters
    const firstName = urlParams.get("FirstName");
    const lastName = urlParams.get("LastName");
    const email = urlParams.get("email");
    const employeeId = urlParams.get("employeeId"); // Add this line to get the employeeId

    // Set values to form fields
    document.getElementById("FirstName").value = firstName;
    document.getElementById("LastName").value = lastName;
    document.getElementById("Email").value = email;

    // Add event listener to the link for changing the password
    document.getElementById("changePasswordLink").addEventListener("click", function (event) {
        count = 1;
        event.preventDefault(); // Prevent the default behavior of the link

        // Toggle the visibility of the password container
        const passwordContainer = document.getElementById("passwordContainer");
        passwordContainer.style.display = passwordContainer.style.display === "none" ? "block" : "none";
    });

    // Your existing code...

    document.getElementById("registrationForm").addEventListener("submit", async function (event) {
        event.preventDefault(); // Prevent the default form submission behavior

        // Reset all error messages
        resetErrorMessages();

         // Validate and get the email
    const emailInput = document.getElementById("Email");
    const email = emailInput.value.trim(); // Trim leading and trailing whitespaces

    if (!isValidEmail(email)) {
        const EmailError4 = document.getElementById("EmailError4");
        if (EmailError4) {
            EmailError4.innerText = 'Incorrect Email';
            EmailError4.style.color = 'red';
            EmailError4.style.fontSize = '10px';
        }
        return;
    } else {
        // Email is valid, display a success message
        setSuccess(emailInput);
    }
        // Check if the provided email is already in use by another user

    // Check if the email is different from the current email
    const currentEmail = await getCurrentEmail(employeeId);
    if (currentEmail !== email) {
        // Check if the provided email is already in use by another user
        const isEmailUsed = await isEmailAlreadyUsed(email, employeeId);

        if (isEmailUsed) {
            const EmailError5 = document.getElementById("EmailError5");
            if (EmailError5) {
                EmailError5.innerText = 'Email is already in use';
                EmailError5.style.color = 'red';
                EmailError5.style.fontSize = '10px';
            }
            return;
        }
    }


        // Retrieve the current employee document from Firestore
    const employeeDocRef = doc(db, employeeCollectionName, employeeId);
    const employeeDoc = await getDoc(employeeDocRef);

    // Get the current password from the Firestore document
    const currentPassword = employeeDoc.data().password;
    const enteredPrevPasswordInput = document.getElementById("PrevPassword");

    if (!enteredPrevPasswordInput) {
        console.error("Password input not found.");
        return;
    }

    let enteredPrevPassword = "";  // Initialize as an empty string

    // Check if the user is updating the password
    if (count === 1) {
        // User is updating the password, get the value from the input field
        enteredPrevPassword = enteredPrevPasswordInput.value;

        // Hash the entered password using the same SHA-256 algorithm
        const hashedEnteredPrevPassword = await hashPassword(enteredPrevPassword);

        // Validate the previous password
        if (hashedEnteredPrevPassword !== currentPassword) {
            const passwordError1 = document.getElementById("passwordError1");
            if (passwordError1) {
                passwordError1.innerText = 'Incorrect previous password';
                passwordError1.style.color = 'red';
                passwordError1.style.fontSize = '10px';
            }
            return;
        } else {
            setSuccess(enteredPrevPasswordInput);
        }
    }

        // Validate and get the new password
        const newPasswordInput = document.getElementById("New_Password");
        const newPassword = newPasswordInput.value.trim(); // Trim leading and trailing whitespaces

        if (count === 1 && newPassword !== "") {
            // User is updating the password, validate the new password
            if (!isValidPassword(newPassword)) {
                const passwordError2 = document.getElementById("passwordError2");
                if (passwordError2) {
                    passwordError2.innerText = 'Password must length 8 and contain at least one digit, one special character, one uppercase letter, and one lowercase letter.';
                    passwordError2.style.color = 'red';
                    passwordError2.style.fontSize = '10px';
                }
                return;
            } else {
                setSuccess(newPasswordInput);
            }
              // Hash the new password before updating the data
    hash_new_password = await hashPassword(newPassword); 
        }

        // Validate and get the confirmation password
        const confirmNewPasswordInput = document.getElementById("Re_Password");
        const confirmNewPassword = confirmNewPasswordInput.value.trim(); // Trim leading and trailing whitespaces

        if (count === 1 && confirmNewPassword !== newPassword) {
            // User is updating the password, validate the confirmation password
            const passwordError3 = document.getElementById("passwordError3");
            if (passwordError3) {
                passwordError3.innerText = 'Not match New Password';
                passwordError3.style.color = 'red';
                passwordError3.style.fontSize = '10px';
            }
            return;
        } else {
            setSuccess(confirmNewPasswordInput);
 
        }
        // Validate the email

   
        
        // Update the document in the Firestore collection using the employeeId
        const updatedData = {
            firstName: document.getElementById("FirstName").value,
            lastName: document.getElementById("LastName").value,
            email: document.getElementById("Email").value,
        };

        // Add the password to updatedData only if the user is updating the password
        if (count === 1) {

            console.log(hash_new_password);
            updatedData.password =hash_new_password ;
        }

        // Use updateDoc from Firestore SDK to update the document
        updateDoc(employeeDocRef, updatedData)
        .then(() => {
            // Display success message at the end of the form
            const successMessage = document.getElementById("successMessage");
            if (successMessage) {
                successMessage.style.display = "block";
        
                // Wait for 1.5 seconds
                setTimeout(() => {
                    // Redirect to employee.html after 1.5 seconds
                    window.location.href = "my_employee.html";
                }, 1500);
            }
        })
            .catch((error) => {
                console.error("Error updating document: ", error);
            });
    });
});

const resetErrorMessages = () => {
    // Reset error messages for previous password
    const passwordError1 = document.getElementById("passwordError1");
    resetErrorMessage(passwordError1);

    // Reset error messages for new password
    const passwordError2 = document.getElementById("passwordError2");
    resetErrorMessage(passwordError2);

    // Reset error messages for confirm password
    const passwordError3 = document.getElementById("passwordError3");
    resetErrorMessage(passwordError3);

      // Reset error messages for confirm password
      const EmailError4 = document.getElementById("EmailError4");
      resetErrorMessage(EmailError4);
      // Reset error messages for confirm password
      const EmailError5 = document.getElementById("EmailError5");
      resetErrorMessage(EmailError5);
};

const resetErrorMessage = (element) => {
    if (element) {
        element.innerText = '';
        element.style.color = '';
        element.style.fontSize = '';

        // Reset the parent element's classes
        const inputControl = element.parentElement;
        if (inputControl) {
            inputControl.classList.remove('error');
            inputControl.classList.remove('success');
        }
    }
};



const setSuccess = element => {
    const inputControl = element.parentElement;
    if (inputControl) {
        const errorDisplay = inputControl.querySelector('.error');
        if (errorDisplay) {
            errorDisplay.innerText = '';
            errorDisplay.style.color = '';  // Reset color
            errorDisplay.style.fontSize = '';  // Reset font size
            inputControl.classList.add('success');
            inputControl.classList.remove('error');
        }
    }
};



const isValidPassword = (password) => {
    // Password must contain at least one digit, one special character, one uppercase letter, and one lowercase letter
    const passwordRegex = /^(?=.*\d)(?=.*[!@#$%^&*])(?=.*[a-z])(?=.*[A-Z]).{8,}$/;
    return passwordRegex.test(password);
};



function isValidEmail(email) {
    // Use a regular expression to validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Function to check if the provided email is already in use by another user
async function isEmailAlreadyUsed(email, currentEmployeeId) {
    // Create a query to check if the email is already used by another user
    const employeeQuery = query(collection(db, employeeCollectionName), where("email", "==", email));

    const querySnapshot = await getDocs(employeeQuery);

    // Check if there are any documents other than the current user with the same email
    return querySnapshot.docs.some(doc => doc.id !== currentEmployeeId);
}
// Function to get the current email of the employee
async function getCurrentEmail(employeeId) {
    const employeeDocRef = doc(db, employeeCollectionName, employeeId);
    const employeeDoc = await getDoc(employeeDocRef);
    return employeeDoc.data().email;
}
     // Function to hash the password
     const hashPassword = async (password) => {
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
        return hashHex.toString();
        // You can store 'hashHex' in your database
    };