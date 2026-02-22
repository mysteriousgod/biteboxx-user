<?php
$apiKey = 'AIzaSyCeM4Ys7Galsz6-FrMTgPAqIyap6-smIDM'; 
$url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=' . $apiKey;
$data = ['sessionInfo' => 'test', 'phoneNumber' => '+911234567890', 'code' => '123456'];
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);
echo "<h1>HTTP Status: $httpCode</h1>";
echo "<pre>" . print_r(json_decode($response, true), true) . "</pre>";
?>
