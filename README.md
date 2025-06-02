# Marketing Analytics using Python, Sentiment Analysis, SQL, and Power BI

This project performs sentiment analysis on customer reviews stored in a SQL Server database using the VADER (Valence Aware Dictionary for sEntiment Reasoning) sentiment analysis tool in Python. The results are classified into categories and buckets and finally saved as a CSV file for further use and visualization.

---

## Features

- Extracts customer review text from SQL Server database
- Applies VADER sentiment analysis on each review
- Classifies reviews into:
  - **Sentiment Scores** (Numerical)
  - **Sentiment Categories** (Positive, Negative, Neutral)
  - **Sentiment Buckets** (e.g., Strongly Positive, Slightly Negative, etc.)
- Exports the final results to a CSV file
- Designed for easy integration into reporting or dashboard pipelines

---

##  Technologies Used

| Tool/Language | Purpose |
|---------------|---------|
| Python (pandas, nltk) | Core scripting and sentiment analysis |
| VADER SentimentIntensityAnalyzer | Natural language sentiment scoring |
| pyodbc | SQL Server connectivity |
| SQL Server | Database storage of raw customer reviews |
| CSV | Final result output format |
| Power BI | For making the dashboard |
---

## Project Workflow

1. **Connect to SQL Server:**
   - Uses `pyodbc` to connect to the database and query customer reviews.
   
2. **Apply VADER Sentiment Analysis:**
   - Tokenizes and scores each review using `SentimentIntensityAnalyzer` from NLTK's VADER module.
   - Calculates the compound score which ranges from -1 (most negative) to +1 (most positive).

3. **Classify Sentiments:**
   - **Category** (based on score):
     - Positive: `compound >= 0.05`
     - Negative: `compound <= -0.05`
     - Neutral: Else
   - **Bucket** (for finer granularity):
     - Strongly Positive: `compound >= 0.6`
     - Slightly Positive: `0.05 ≤ compound < 0.6`
     - Neutral: `-0.05 < compound < 0.05`
     - Slightly Negative: `-0.6 < compound ≤ -0.05`
     - Strongly Negative: `compound ≤ -0.6`

4. **Export Results to CSV:**
   - The full DataFrame including review, score, category, and bucket is saved to `Sentiment_Results.csv`.
     
5. **Export all tables to Power BI:**
   - All the tables are exported to Power BI and used DAX funtions to create an interactive dashboard.

---

## Example Output

| Review | Sentiment Score | Sentiment Category | Sentiment Bucket |
|--------|------------------|---------------------|------------------|
| "Excellent product, very useful!" | 0.89 | Positive | Strongly Positive |
| "Okayish, could be better." | 0.03 | Neutral | Neutral |
| "Terrible experience." | -0.76 | Negative | Strongly Negative |

---





