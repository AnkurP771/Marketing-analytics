import pandas as pd
import pyodbc
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer

# First, I make sure the VADER sentiment lexicon is downloaded so I can use it for analysis
nltk.download('vader_lexicon')

def get_reviews():
    """
    I connect to the SQL Server database and fetch the customer reviews.
    This function returns a DataFrame with all the review details.
    """
    connection_string = (
        "Driver={SQL Server};"
        "Server=ALI-LT2024\\SQLEXPRESS;"
        "Database=PortfolioProject_MarketingAnalytics;"
        "Trusted_Connection=yes;"
    )
    conn = pyodbc.connect(connection_string)
    query = "SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText FROM fact_customer_reviews"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# I get the review data from the database
reviews_df = get_reviews()

# Now, I create an instance of the VADER sentiment analyzer
analyzer = SentimentIntensityAnalyzer()

def get_sentiment_score(text):
    """
    Given a piece of review text, I calculate its sentiment score using VADER.
    I return the 'compound' score which tells me how positive or negative the text is overall.
    """
    return analyzer.polarity_scores(text)['compound']

def label_sentiment(score, stars):
    """
    Here, I decide the final sentiment label by combining the sentiment score from VADER
    and the star rating given by the customer.
    This way, I consider both what the customer wrote and how they rated.
    """
    if score > 0.05:
        if stars >= 4:
            return "Positive"
        elif stars == 3:
            return "Mixed Positive"
        else:
            return "Mixed Negative"
    elif score < -0.05:
        if stars <= 2:
            return "Negative"
        elif stars == 3:
            return "Mixed Negative"
        else:
            return "Mixed Positive"
    else:
        if stars >= 4:
            return "Positive"
        elif stars <= 2:
            return "Negative"
        else:
            return "Neutral"

def bucketize_score(score):
    """
    To better understand the distribution of sentiment scores, I group the compound scores
    into buckets that represent ranges from very negative to very positive.
    """
    if score >= 0.5:
        return "0.5 to 1.0"
    elif score >= 0.0:
        return "0.0 to 0.49"
    elif score >= -0.5:
        return "-0.49 to 0.0"
    else:
        return "-1.0 to -0.5"

# I apply the sentiment scoring function to every review's text
reviews_df["Score"] = reviews_df["ReviewText"].apply(get_sentiment_score)

# Then, I combine the score and star rating to label the sentiment category
reviews_df["Sentiment"] = reviews_df.apply(lambda row: label_sentiment(row["Score"], row["Rating"]), axis=1)

# I also assign each score to its respective bucket
reviews_df["Bucket"] = reviews_df["Score"].apply(bucketize_score)

# Let's look at the first few rows to verify everything looks good
print(reviews_df.head())

# Finally, I save the processed data with sentiment labels to a CSV file for later use
reviews_df.to_csv("customer_reviews_sentiment_output.csv", index=False)
