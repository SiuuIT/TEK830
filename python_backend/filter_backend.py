import pandas as pd
import numpy as np
from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from rapidfuzz import fuzz

# --- Load Excel file ---
FILE_PATH = r"C:\Users\Theodor\Downloads\FY24.xlsx"
df = pd.read_excel(FILE_PATH)
df = df.replace([np.nan, np.inf, -np.inf], None)  # Fix JSON issues

# --- Initialize FastAPI ---
app = FastAPI()

# --- Small synonym dictionary ---
synonyms = {
    "lavatory": ["toilet", "lavatory", "WC", "washroom"],
    "coworker": ["coworker", "co-worker", "colleague"],
    "office": ["office", "workspace", "workplace"]
}


# --- Helper function: normalize input using synonyms ---
def normalize_input(user_input):
    for key, variants in synonyms.items():
        if user_input.lower() in [v.lower() for v in variants]:
            return key
    return user_input


# --- Helper function: fuzzy filter ---
def fuzzy_filter(df, column, user_input, threshold):
    """
    Return rows where df[column] is similar to user_input above threshold.
    """
    cleaned_column = df[column].fillna("").astype(str).str.strip().str.lower()
    cleaned_input = str(user_input).strip().lower()

    mask = cleaned_column.apply(lambda x: fuzz.ratio(x, cleaned_input) >= threshold)
    return df[mask]


# --- Endpoints ---
@app.get("/filter")
def filter_data(
        column: str = Query(..., description="Column name to filter on"),
        value: str = Query(..., description="Value to filter for"),
        limit: int = Query(100, description="Max number of rows to return"),
        threshold: int = Query(60, description="Similarity threshold (0-100)")
):
    # Check column exists
    if column not in df.columns:
        return JSONResponse(
            status_code=400,
            content={"error": f"Column '{column}' not found in dataset"}
        )

    # Normalize input via synonyms
    normalized_value = normalize_input(value)

    # Fuzzy filter
    filtered = fuzzy_filter(df, column, normalized_value, threshold).head(limit)

    # Convert to JSON
    result = filtered.to_dict(orient="records")
    return result


@app.get("/columns")
def list_columns():
    """Return available columns for frontend or testing."""
    return {"columns": df.columns.tolist()}