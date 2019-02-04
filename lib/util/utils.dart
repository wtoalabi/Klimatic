final appID = "5d18d1b8ccdc389241bc74f90f507b7f";
final defaultCity = "FCT";

String capitalize(string){
  return "${string[0].toUpperCase()}${string.substring(1)}";
}

num turnToCelsius(temp) {
  num value = (temp - 32) * 5 / 9;
  return num.parse(value.toStringAsFixed(1));
}