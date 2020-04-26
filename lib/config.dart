const env = 'dev'; // env can be prod or dev only

const devAuthKey = 'AIzaSyAG3rnMfKWn-53A0FVZs5lr8U_Xr8Q8c5U';
const prodAuthKey = 'AIzaSyCuD6tddRvgtt0ezlCAMIoBYKQXc_1_0fU';
const authUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';

const devApi = 'https://flutterdev-186d8.firebaseio.com/';
const prodApi = 'https://flutterprod-94edb.firebaseio.com/';
const api = (env == 'dev') ? devApi : prodApi;
