#!/bin/bash
# Log Analyzer: Detect Packet Loss and File Corruption using grep + awk

LOGFILE="company.log"
OUTPUT="report.txt"

if [[ ! -f $LOGFILE ]]; then
    echo "❌ Log file not found!"
    exit 1
fi

echo "Analyzing log file: $LOGFILE ..."
echo "---------------------------------------------" > $OUTPUT
echo "Packet Loss and File Corruption Report" >> $OUTPUT
echo "---------------------------------------------" >> $OUTPUT

# Find packet loss entries
echo -e "\n Packet Loss Detected:" >> $OUTPUT
grep -i "packet loss" $LOGFILE | awk '{print $1, $2, $4, $5, $6, $7, $8, $9}' >> $OUTPUT

# Find timeout or unreachable hosts
echo -e "\n Network Timeouts / Unreachable Hosts:" >> $OUTPUT
grep -Ei "timeout|unreachable" $LOGFILE | awk '{print $1, $2, $0}' >> $OUTPUT

# Find corrupted or checksum mismatch files
echo -e "\n File Corruption / Checksum Errors:" >> $OUTPUT
grep -Ei "corrupt|checksum|mismatch" $LOGFILE | awk '{print $1, $2, $0}' >> $OUTPUT

# Summary statistics
echo -e "\n Summary:" >> $OUTPUT
PL_COUNT=$(grep -ci "packet loss" $LOGFILE)
CORR_COUNT=$(grep -Eci "corrupt|checksum|mismatch" $LOGFILE)
TIMEOUT_COUNT=$(grep -Eci "timeout|unreachable" $LOGFILE)
TOTAL=$(wc -l < $LOGFILE)

awk -v pl=$PL_COUNT -v corr=$CORR_COUNT -v to=$TIMEOUT_COUNT -v total=$TOTAL '
BEGIN {
    print "Total log entries:", total
    print "Packet loss events:", pl
    print "Corruption events:", corr
    print "Timeout events:", to
    print "---------------------------------------------"
}' >> $OUTPUT

echo "✅ Analysis complete. Report saved in $OUTPUT"
echo
cat $OUTPUT
