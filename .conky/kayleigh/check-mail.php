<?php
include_once 'env.php';

$server = '{imap.fastmail.com:993/ssl}';
$connection = imap_open($server, $username, $password);

$status = imap_status($connection, "$server" . "INBOX", SA_ALL);

echo $status ? $status->messages : 'ERR';

imap_close($connection);
