import React,{ useEffect,useState,useRef } from 'react';
import {useDispatch ,useSelector } from 'react-redux';
import axios from 'axios';
import toast,{Toaster} from 'react-hot-toast';
import {io} from 'socket.io-client';
//import {IUser} from '../../../src/models/user.model';

interface user {
     email: string;
     firstname: string;
     lastname: string;
     password: string;
     registerdate: Date;
 }

const Messenger = () => {

     const [users, setUsers] = useState([])

     const loadUsers = async () =>{
          const res = await axios.get('http://localhost:4000/home')
          setUsers(res.data);
     }

     useEffect(() => {
          loadUsers()
     }, [])

     const scrollRef = useRef();
     const socket = useRef();

     const [currentfriend, setCurrentFriend] = useState('');
     const [newMessage, setNewMessage] = useState('');

     const [activeUser, setActiveUser] = useState([]);
     const [socketMessage, setSocketMessage] = useState('');
     const [typingMessage, setTypingMessage] = useState('');

  return (
       <div>

<div className='row'>
     <div className='col-3'>
          <div className='left-side'>
               <div className='top'>
                    <div className='image-name'>
                         <div className='image'>
                              <img src=''/>

                         </div>
                         <div className='name'>
                         <h3></h3>
                         </div>
                       </div>

                       <div className='icons'>
            <div className='icon'></div>
            <div className='icon'></div>

            <div className=''>
                 <h3>Dark Mode </h3>
            <div className='on'>
                 <label htmlFor='dark'>ON</label>
                 <input type="radio" value="dark" name="theme" id="dark" />
                 </div>

                 <div className='of'>
                 <label htmlFor='white'>OFF</label>
                 <input type="radio" value="white" name="theme" id="white" />
                 </div>

                 <div className='logout'>Logout</div>

            </div>
                       </div>
               </div>

               <div className='friend-search'>
                    <div className='search'>
                    <button></button>
  <input type="text" placeholder='Search' className='form-control' />
                    </div>
               </div>

               <div className='friends'>               
                    
                    {/* {users.map((user) => {
                         return <div>
                              <h1>{user.firstname}</h1>
                         </div>
                    })} */}

               </div>

          </div>
                      
                 </div>            

            </div>

       </div>
  )
};

export default Messenger;