package main

import (
	"database/sql"
	"encoding/base64"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"golang.org/x/crypto/bcrypt"
)

// ALL STRUCT
type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Password string `json:"password"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Status   string `json:"status"`
}

type Kid struct {
	IDKids           string `json:"id_kids"`
	Name             string `json:"name_kids"`
	BirthDate        string `json:"birth_date"`
	Sex              string `json:"sex"`
	Allergies        string `json:"allergies"`
	SpecialNeeds     string `json:"special_needs"`
	GuardianName     string `json:"guardian_name"`
	GuardianPhone    string `json:"guardian_phone"`
	SecGuardianName  string `json:"sec_guardian_name"`
	SecGuardianPhone string `json:"sec_guardian_phone"`
	Notes            string `json:"notes"`
	UserID           string `json:"user_id"`
}

type NotesHistory struct {
	IDNotesHistory int    `json:"id_notes_history"`
	IDKids         string `json:"id_kids"`
	IDDaycare      string `json:"id_daycare"`
	NotesDate      string `json:"notes_date"`
	Caretaker      string `json:"caretaker"`
	Notes          string `json:"notes"`
	NoteImage      string `json:"note_image"`
	NoteImageName  string `json:"note_image_name"`
	DaycareName    string `json:"daycare_name"`
}

type Daycare struct {
	ID   string `json:"id_daycare"`
	Name string `json:"name_daycare"`
}

type EnrollHistory struct {
	IDKids              string `json:"id_kids"`
	IDDaycare           string `json:"id_daycare"`
	EnrollDate          string `json:"enroll_date"`
	EnrollCaretaker     string `json:"enroll_caretaker"`
	DaycareName         string `json:"name_daycare"`
	CheckoutTime        string `json:"checkout_time"`
	CheckoutCaretaker   string `json:"checkout_caretaker"`
	Food                string `json:"food"`
	FoodCaretaker       string `json:"food_caretaker"`
	Snack               string `json:"snack"`
	Sleep               string `json:"sleep"`
	Assignment          string `json:"assignment"`
	AssignmentCaretaker string `json:"assignment_caretaker"`
	Medicine            string `json:"medicine"`
	MedicineCaretaker   string `json:"medicine_caretaker"`
	Mood                string `json:"mood"`
	EnrollNote          string `json:"enroll_note"`
}

type EnrollRequest struct {
	IDKids          string `json:"id_kids" binding:"required"`
	EnrollCode      string `json:"enroll_code" binding:"required"`
	EnrollCaretaker string `json:"enroll_caretaker"`
	EnrollNote      string `json:"enroll_note"`
}

type AccessRequest struct {
	IDUser     string `json:"id_user" binding:"required"`
	IDDaycare  string `json:"id_daycare" binding:"required"`
	AccessCode string `json:"access_code" binding:"required"`
}

type AccessResponse struct {
	LinkCCTV string `json:"link_cctv"`
}

// Database connection
var db *sql.DB

func init() {
	var err error
	db, err = sql.Open("mysql", "root:@tcp(localhost:3306)/NURTURE_NEST")
	if err != nil {
		panic(err)
	}

	if err = db.Ping(); err != nil {
		panic(err)
	}
}

func registerUser(c *gin.Context) {
	var user User

	// Attempt to bind the JSON body to the User struct
	if err := c.ShouldBindJSON(&user); err != nil {
		log.Printf("Error binding JSON: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Check if the username already exists
	var existingUserCount int
	err := db.QueryRow("SELECT COUNT(*) FROM USER WHERE USERNAME = ?", user.Username).Scan(&existingUserCount)
	if err != nil {
		log.Printf("Error checking username: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check username"})
		return
	}

	if existingUserCount > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Username already exists"})
		return
	}

	// Count existing users to generate a new ID
	var userCount int
	err = db.QueryRow("SELECT COUNT(*) FROM USER").Scan(&userCount)
	if err != nil {
		log.Printf("Error counting users: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to count users"})
		return
	}

	// Generate the new user ID
	newID := userCount + 1
	user.ID = fmt.Sprintf("%08d", newID) // Format ID to be 8 digits

	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("Error hashing password: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Store user in the database
	_, err = db.Exec("INSERT INTO USER (ID_USER, USERNAME, PASSWORD, NAME_USER, EMAIL, STATUS) VALUES (?, ?, ?, ?, ?, 'A')",
		user.ID, user.Username, hashedPassword, user.Name, user.Email)
	if err != nil {
		log.Printf("Error registering user: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "User registered successfully", "id": user.ID})
}

func loginUser(c *gin.Context) {
	var user User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var hashedPassword string
	var userID string
	var name string
	err := db.QueryRow("SELECT ID_USER, NAME_USER, PASSWORD FROM USER WHERE USERNAME = ?", user.Username).Scan(&userID, &name, &hashedPassword)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid username or password"})
		return
	}

	// Verify the password
	if err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(user.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid username or password"})
		return
	}

	// Log the successful login by inserting into LOGIN_HISTORY
	err = logLoginHistory(userID)
	if err != nil {
		log.Printf("Error logging login history: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to log login history"})
		return
	}

	// Login successful - respond with userID and name
	c.JSON(http.StatusOK, gin.H{
		"message":   "Login successful",
		"id_user":   userID,
		"NAME_USER": name,
	})
}

func logLoginHistory(userID string) error {
	query := "INSERT INTO LOGIN_HISTORY (ID_USER) VALUES (?)"
	_, err := db.Exec(query, userID)
	return err
}

func getKidsByUserID(c *gin.Context) {
	userID := c.Param("id")

	// Pastikan userID memiliki panjang 8 karakter
	if len(userID) < 8 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID must be at least 8 characters"})
		return
	}

	// Query untuk mengambil data dari tabel KIDS
	var kids []Kid
	query := "SELECT ID_KIDS, NAME_KIDS, BIRTH_DATE, SEX, ALLERGIES, SPECIAL_NEEDS, GUARDIAN_NAME, GUARDIAN_PHONE, SEC_GUARDIAN_NAME, SEC_GUARDIAN_PHONE, NOTES FROM KIDS WHERE ID_KIDS LIKE ?"
	rows, err := db.Query(query, userID+"%") // Mencari ID_KIDS yang dimulai dengan userID
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query database"})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var kid Kid
		if err := rows.Scan(&kid.IDKids, &kid.Name, &kid.BirthDate, &kid.Sex, &kid.Allergies, &kid.SpecialNeeds, &kid.GuardianName, &kid.GuardianPhone, &kid.SecGuardianName, &kid.SecGuardianPhone, &kid.Notes); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to scan row"})
			return
		}
		kids = append(kids, kid) // Menambahkan setiap anak ke slice kids
	}

	if len(kids) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "No kids found for the given user ID"})
		return
	}

	c.JSON(http.StatusOK, kids)
}

// Fungsi untuk menghitung jumlah anak tanpa karakter wildcard pada query
func countKids(userID string) (int, error) {
	var count int
	query := "SELECT COUNT(*) FROM KIDS WHERE ID_USER = ?"
	err := db.QueryRow(query, userID).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}

// Fungsi untuk menambahkan anak ke tabel KIDS dengan validasi tambahan
func addKid(c *gin.Context) {
	var kid Kid
	if err := c.ShouldBindJSON(&kid); err != nil {
		log.Printf("Error binding JSON: %v", err) // Log error binding
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Validasi input
	if kid.UserID == "" || kid.Name == "" {
		log.Printf("Validation error: UserID: %s, Name: %s", kid.UserID, kid.Name) // Log nilai
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID and Name are required"})
		return
	}

	// Hitung jumlah anak yang terdaftar untuk user
	count, err := countKids(kid.UserID)
	if err != nil {
		log.Printf("Error counting kids: %v", err) // Log error saat menghitung
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to count kids"})
		return
	}

	// Generate ID_KIDS
	kidCount := count + 1
	kid.IDKids = fmt.Sprintf("%s%02d", kid.UserID, kidCount)

	// Cek apakah ID_KIDS sudah ada sebelum insert
	var existingKidID string
	checkQuery := "SELECT ID_KIDS FROM KIDS WHERE ID_KIDS = ?"
	err = db.QueryRow(checkQuery, kid.IDKids).Scan(&existingKidID)
	if err != nil && err != sql.ErrNoRows {
		log.Printf("Error checking kid ID: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check kid ID"})
		return
	}
	if existingKidID != "" {
		log.Printf("Duplicate ID_KIDS: %s already exists", kid.IDKids)
		c.JSON(http.StatusConflict, gin.H{"error": "Kid ID already exists"})
		return
	}

	// Simpan data anak ke database
	query := `INSERT INTO KIDS (ID_KIDS, NAME_KIDS, BIRTH_DATE, SEX, ALLERGIES, SPECIAL_NEEDS, GUARDIAN_NAME, GUARDIAN_PHONE, SEC_GUARDIAN_NAME, SEC_GUARDIAN_PHONE, NOTES, ID_USER) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
	_, err = db.Exec(query, kid.IDKids, kid.Name, kid.BirthDate, kid.Sex, kid.Allergies, kid.SpecialNeeds, kid.GuardianName, kid.GuardianPhone, kid.SecGuardianName, kid.SecGuardianPhone, kid.Notes, kid.UserID)
	if err != nil {
		log.Printf("Error inserting kid: %v", err) // Log error saat insert
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert the kid"})
		return
	}

	c.JSON(http.StatusCreated, kid)
}

func getNotesHistory(c *gin.Context) {
	kidID := c.Param("id_kids")

	log.Println("Received request for kidID:", kidID)

	query := `
        SELECT nh.id_notes_history, nh.id_kids, nh.id_daycare, nh.notes_date, nh.caretaker, nh.notes, nh.note_image, nh.note_image_name, d.name_daycare
        FROM NOTES_HISTORY nh
        JOIN DAYCARE d ON nh.id_daycare = d.id_daycare
        WHERE nh.id_kids = ?
        ORDER BY nh.notes_date DESC
    `

	rows, err := db.Query(query, kidID)
	if err != nil {
		log.Printf("Query execution error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Query execution error"})
		return
	}
	defer rows.Close()

	var notesHistory []NotesHistory
	for rows.Next() {
		var note NotesHistory
		var noteImage []byte // Menggunakan []byte untuk menampung data LONGBLOB

		err := rows.Scan(
			&note.IDNotesHistory,
			&note.IDKids,
			&note.IDDaycare,
			&note.NotesDate,
			&note.Caretaker,
			&note.Notes,
			&noteImage, // Scan ke []byte
			&note.NoteImageName,
			&note.DaycareName,
		)
		if err != nil {
			log.Printf("Data scan error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Data scan error"})
			return
		}

		// Mengonversi LONGBLOB menjadi Base64
		if noteImage != nil {
			note.NoteImage = base64.StdEncoding.EncodeToString(noteImage) // Encode ke Base64
		} else {
			note.NoteImage = ""
		}

		notesHistory = append(notesHistory, note)
	}

	c.JSON(http.StatusOK, notesHistory)
}

func addNote(c *gin.Context) {
	var note NotesHistory

	// Ambil data form
	note.IDKids = c.PostForm("id_kids")
	note.IDDaycare = c.PostForm("id_daycare")
	note.Caretaker = c.PostForm("caretaker")
	note.Notes = c.PostForm("notes")
	note.NoteImageName = c.PostForm("note_image_name")

	// Validasi field wajib
	if note.IDKids == "" || note.Notes == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "IDKids and Notes are required"})
		return
	}

	// Baca file gambar dari form-data
	file, _, err := c.Request.FormFile("note_image")
	if err != nil {
		log.Printf("Error reading file: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read file"})
		return
	}
	defer file.Close()

	// Baca file gambar sebagai byte array
	imageData, err := io.ReadAll(file)
	if err != nil {
		log.Printf("Error reading image file: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read image file"})
		return
	}

	// Insert note beserta gambar ke database
	query := `INSERT INTO NOTES_HISTORY (id_kids, id_daycare, caretaker, notes, note_image, note_image_name) 
              VALUES (?, ?, ?, ?, ?, ?)`
	_, err = db.Exec(query, note.IDKids, note.IDDaycare, note.Caretaker, note.Notes, imageData, note.NoteImageName)
	if err != nil {
		log.Printf("Error inserting note with image: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert note with image"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Note with image added successfully"})
}

func getEnrollHistory(c *gin.Context) {
	idKids := c.Param("id_kids")

	// Query untuk mengambil data enroll_history dan nama daycare
	rows, err := db.Query(`
        SELECT eh.id_kids, eh.id_daycare, eh.enroll_date, d.name_daycare
        FROM ENROLL_HISTORY eh
        JOIN DAYCARE d ON eh.id_daycare = d.id_daycare
        WHERE eh.id_kids = ?`, idKids)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Query execution error"})
		return
	}
	defer rows.Close()

	var enrollHistories []EnrollHistory

	// Iterasi melalui hasil
	for rows.Next() {
		var enroll EnrollHistory
		if err := rows.Scan(&enroll.IDKids, &enroll.IDDaycare, &enroll.EnrollDate, &enroll.DaycareName); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Row scan error"})
			return
		}
		enrollHistories = append(enrollHistories, enroll)
	}

	// Kembalikan hasil
	c.JSON(http.StatusOK, enrollHistories)
}

func getEnrollHistoryToday(c *gin.Context) {
	idKids := c.Param("id_kids")
	today := time.Now().Format("2006-01-02")

	// Query untuk mengambil semua data dari ENROLL_HISTORY dan DAYCARE
	rows, err := db.Query(`
        SELECT eh.id_kids, eh.id_daycare, eh.enroll_date, eh.enroll_caretaker, 
               eh.checkout_time, eh.checkout_caretaker, eh.food, eh.food_caretaker, eh.snack, 
               eh.sleep, eh.assignment, eh.assignment_caretaker, eh.medicine, eh.medicine_caretaker, 
               eh.mood, eh.enroll_note, d.name_daycare
        FROM ENROLL_HISTORY eh
        JOIN DAYCARE d ON eh.id_daycare = d.id_daycare
        WHERE eh.id_kids = ? AND DATE(eh.enroll_date) = ?`, idKids, today)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Query execution error"})
		return
	}
	defer rows.Close()

	var enrollHistories []EnrollHistory

	// Iterasi hasil query dan masukkan ke struct dengan penanganan nilai NULL
	for rows.Next() {
		var enroll EnrollHistory
		var checkoutTime, checkoutCaretaker, food, foodCaretaker, snack, sleep, assignment, assignmentCaretaker, medicine, medicineCaretaker, mood, enrollNote sql.NullString

		err := rows.Scan(
			&enroll.IDKids, &enroll.IDDaycare, &enroll.EnrollDate, &enroll.EnrollCaretaker,
			&checkoutTime, &checkoutCaretaker, &food, &foodCaretaker, &snack,
			&sleep, &assignment, &assignmentCaretaker, &medicine, &medicineCaretaker,
			&mood, &enrollNote, &enroll.DaycareName,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Row scan error"})
			return
		}

		// Assign nilai kolom dengan penanganan NULL
		enroll.CheckoutTime = checkoutTime.String
		enroll.CheckoutCaretaker = checkoutCaretaker.String
		enroll.Food = food.String
		enroll.FoodCaretaker = foodCaretaker.String
		enroll.Snack = snack.String
		enroll.Sleep = sleep.String
		enroll.Assignment = assignment.String
		enroll.AssignmentCaretaker = assignmentCaretaker.String
		enroll.Medicine = medicine.String
		enroll.MedicineCaretaker = medicineCaretaker.String
		enroll.Mood = mood.String
		enroll.EnrollNote = enrollNote.String

		enrollHistories = append(enrollHistories, enroll)
	}

	// Kembalikan hasil dalam bentuk JSON
	c.JSON(http.StatusOK, enrollHistories)
}

func enrollKids(c *gin.Context) {
	var enrollRequest EnrollRequest

	// Bind the request body to the EnrollRequest struct
	if err := c.ShouldBindJSON(&enrollRequest); err != nil {
		log.Printf("Error binding JSON: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Get ID_DAYCARE from ENROLL_CODE
	var idDaycare string
	err := db.QueryRow("SELECT ID_DAYCARE FROM ENROLL_CODE WHERE ENROLL_CODE = ?", enrollRequest.EnrollCode).Scan(&idDaycare)
	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "ENROLL_CODE not found"})
		} else {
			log.Printf("Error querying ENROLL_CODE: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		}
		return
	}

	// Check for duplicate enrollment
	var existingCount int
	err = db.QueryRow("SELECT COUNT(*) FROM ENROLL_HISTORY WHERE ID_KIDS = ? AND ID_DAYCARE = ? AND DATE(ENROLL_DATE) = DATE(CURRENT_TIMESTAMP)",
		enrollRequest.IDKids, idDaycare).Scan(&existingCount)
	if err != nil {
		log.Printf("Error checking for existing enrollment: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if existingCount > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Enrollment already exists for the given kid and daycare on the same date"})
		return
	}

	// Insert into ENROLL_HISTORY
	_, err = db.Exec("INSERT INTO ENROLL_HISTORY (ID_KIDS, ID_DAYCARE, ENROLL_CARETAKER, ENROLL_NOTE) VALUES (?, ?, ?, ?)",
		enrollRequest.IDKids, idDaycare, enrollRequest.EnrollCaretaker, enrollRequest.EnrollNote)
	if err != nil {
		log.Printf("Error inserting into ENROLL_HISTORY: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to enroll kid"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":          "Enrollment successful",
		"id_kids":          enrollRequest.IDKids,
		"id_daycare":       idDaycare,
		"enroll_caretaker": enrollRequest.EnrollCaretaker,
		"enroll_note":      enrollRequest.EnrollNote,
	})
}

func getNotesToday(c *gin.Context) {
	kidID := c.Param("id_kids")

	log.Println("Received request for kidID:", kidID)

	query := `
        SELECT nh.id_notes_history, nh.id_kids, nh.id_daycare, nh.notes_date, nh.caretaker, nh.notes, nh.note_image, nh.note_image_name, d.name_daycare
        FROM NOTES_HISTORY nh
        JOIN DAYCARE d ON nh.id_daycare = d.id_daycare
        WHERE nh.id_kids = ? and nh.notes_date = CURRENT_DATE()
        ORDER BY nh.notes_date ASC
    `

	rows, err := db.Query(query, kidID)
	if err != nil {
		log.Printf("Query execution error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Query execution error"})
		return
	}
	defer rows.Close()

	var notesHistory []NotesHistory
	for rows.Next() {
		var note NotesHistory
		var noteImage []byte // Menggunakan []byte untuk menampung data LONGBLOB

		err := rows.Scan(
			&note.IDNotesHistory,
			&note.IDKids,
			&note.IDDaycare,
			&note.NotesDate,
			&note.Caretaker,
			&note.Notes,
			&noteImage, // Scan ke []byte
			&note.NoteImageName,
			&note.DaycareName,
		)
		if err != nil {
			log.Printf("Data scan error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Data scan error"})
			return
		}

		// Mengonversi LONGBLOB menjadi Base64
		if noteImage != nil {
			note.NoteImage = base64.StdEncoding.EncodeToString(noteImage) // Encode ke Base64
		} else {
			note.NoteImage = ""
		}

		notesHistory = append(notesHistory, note)
	}

	c.JSON(http.StatusOK, notesHistory)
}

// Fungsi untuk memeriksa akses CCTV
func accessCCTV(c *gin.Context) {
	var request AccessRequest

	// Bind JSON ke struct
	if err := c.ShouldBindJSON(&request); err != nil {
		log.Printf("Error binding JSON: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Cek di tabel CCTV_ACCESS
	var linkCCTV string
	query := "SELECT LINK_CCTV FROM CCTV_ACCESS WHERE ID_DAYCARE = ? AND ACCESS_CODE = ?"
	err := db.QueryRow(query, request.IDDaycare, request.AccessCode).Scan(&linkCCTV)

	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusForbidden, gin.H{"error": "Invalid ID_DAYCARE or ACCESS_CODE"})
			return
		}
		log.Printf("Database query error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database query failed"})
		return
	}

	historyQuery := "INSERT INTO CCTV_ACCESS_HISTORY (ID_DAYCARE, ID_USER) VALUES (?, ?)"
	_, err = db.Exec(historyQuery, request.IDDaycare, request.IDUser)
	if err != nil {
		log.Printf("Failed to log access history: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to log access history"})
		return
	}

	response := AccessResponse{LinkCCTV: linkCCTV}
	c.JSON(http.StatusOK, response)
}

func CORSMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		c.Next()
	}
}

// Main function
func main() {
	router := gin.Default()
	router.Use(CORSMiddleware())

	router.POST("/login", loginUser)
	router.POST("/register", registerUser)
	router.POST("/kids", addKid)
	router.POST("/enroll", enrollKids)
	router.GET("/kids/:id", getKidsByUserID)
	router.GET("/notes/:id_kids", getNotesHistory)
	router.GET("/notes_today/:id_kids", getNotesToday)
	router.GET("/enroll_history/:id_kids", getEnrollHistory)
	router.GET("/enroll_history_today/:id_kids", getEnrollHistoryToday)
	router.POST("/notes", addNote)
	router.POST("/cctv", accessCCTV)

	// Start the server
	router.Run(":3000")
}
