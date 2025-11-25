import pandas as pd
import matplotlib.pyplot as plt

def cusum_anomaly_detection(series, threshold, drift):
    sum = 0
    g_plus = 0
    g_minus = 0
    t_abnormal = []
    for i in range(1, len(series)):
        sum = series[i] - series[i - 1]
        g_plus = max(g_plus + sum - drift, 0)
        g_minus = max(g_minus - sum - drift, 0)
        if(g_plus > threshold or g_minus > threshold):
            t_abnormal.append(i - 1)
            g_plus = 0
            g_minus = 0
    return t_abnormal

def plot_series(col, s, abnormal_list):
    plt.figure(figsize=(12, 5))

    # Plot the main series
    plt.plot(s.index, s.values, label='Series')
    plt.title(col)
    # Abnormal points (as circles)
    plt.scatter(
        s.loc[abnormal_list].index,
        s.loc[abnormal_list].values,
        s=70,
        edgecolors = 'black',
        facecolors='red',  # hollow circle
        marker='o',  # circle marker
        linewidths=2,
        label='Anomaly',
        zorder = 5
    )

    plt.legend()
    plt.show()

#constants
THRESHOLD = 200
DRIFT = 50

df = pd.read_csv("csv_files/temperatures.csv")
df = df.drop("Timestamp", axis = 1)

#to integers
df = df * 100

for col in df.columns:
    temp = df[col].astype(int)
    t_abnormal = cusum_anomaly_detection(temp, THRESHOLD, DRIFT)
    plot_series(col, temp, t_abnormal)
    with open(f"python_csv_files/python_{col.strip()}.csv", "w") as g:
        for i in range(0, len(temp)):
            label = 0
            if i in t_abnormal:
                label = 1
            g.write(f"{i}, {label}\n")
