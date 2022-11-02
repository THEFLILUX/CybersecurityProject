import React from 'react';
import { Link,useNavigate } from 'react-router-dom';
//import { userLogin } from '../store/actions/authAction';
import {useDispatch,useSelector} from "react-redux"
//import { ERROR_CLEAR, SUCCESS_MESSAGE_CLEAR } from '../store/types/authType';

const Login = () => {
    return( 
        <div className='register'>
        <div className='card'>
             <div className='card-header'>
                <h3>Login</h3>
             </div>

        <div className='card-body'>
                <form>
                    

                    <div className='form-group'>
                        <label htmlFor='email'>Email</label>
                    <input type="email" name="email" className='form-control' placeholder='Email' id='email' /> 
                    </div>

                    <div className='form-group'>
                        <label htmlFor='password'>Password</label>
                    <input type="password" name="password" className='form-control' placeholder='Password' id='password' /> 
                    </div> 


                    <div className='form-group'>
                    <input type="submit" value="login" className='btn' />
                    </div>


                    <div className='form-group'>
        <span><Link to="/messenger/register"> Don't have any Account </Link></span>
                    </div>  
                </form> 
        </div>


                    </div> 

        </div>
    )
};

export default Login;