<?php
# $ php -f db-connect-test.php

$dbname = 'mysql';
$dbuser = 'root';
$dbpass = 'password';
$dbhost = 'localhost';

$connect = mysql_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");
mysql_select_db($dbname) or die("Could not open the db '$dbname'");

echo "Connected to database: $dbname on $dbhost sucessfully<br />\n";
echo "<br />\n";
$test_query = "SHOW TABLES FROM $dbname";
$result = mysql_query($test_query);

echo "Reading tables...<br />\n";
echo "<br />\n";
$tblCnt = 0;
while($tbl = mysql_fetch_array($result)) {
  $tblCnt++;
  echo $tbl[0]."<br />\n";
}
echo "<br />\n";
if (!$tblCnt) {
  echo "There are no tables<br />\n";
} else {
  echo "There are $tblCnt tables<br />\n";
}
?>
