//This code calculate the date of J.D. Julian Date
#include <iostream>
#include <iomanip>
#include <cmath>
using namespace std;
int main()
{
	int year, month, day, hour, minute, second;
	double JD;
	cout << "Enter the year: ";
	cin >> year;
	cout << "Enter the month: ";
	cin >> month;
	cout << "Enter the day: ";
	cin >> day;
	cout << "Enter the hour: ";
	cin >> hour;
	cout << "Enter the minute: ";
	cin >> minute;
	cout << "Enter the second: ";
	cin >> second;
	if (month == 1 || month == 2)
	{
		year = year - 1;
		month = month + 12;
	}
	JD = 365.25 * year + 30.6001 * (month + 1) + day + hour / 24.0 + minute / 1440.0 + second / 86400.0 + 1720981.5;
	cout << "The Julian Date is: " << setprecision(9) <<JD << endl;
	return JD;
}


