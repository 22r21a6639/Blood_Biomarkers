from flask import Flask, request, jsonify
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier

app = Flask(__name__)

# Load the dataset and train the model
dataset = pd.read_csv('dataset.csv')
x = dataset.iloc[:, :-1].values
y = dataset.iloc[:, -1].values

sc = StandardScaler()
x = sc.fit_transform(x)

model = KNeighborsClassifier(n_neighbors=5, metric='minkowski', p=2)
model.fit(x, y)

@app.route('/')
def home():
    return "Server is running!"

@app.route('/predict', methods=['POST'])
def predict():
    if request.is_json:
        data = request.get_json()
        print("Received JSON data:", data)  # Debugging line
        input_data = np.array([data['values']])
        scaled_data = sc.transform(input_data)
        prediction = model.predict(scaled_data)
        return jsonify({'prediction': prediction[0]})
    else:
        print("Unsupported Media Type")  # Debugging line
        return jsonify({"error": "Unsupported Media Type"}), 415

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
