import{
  BrowserRouter,
  Routes,
  Route
} from "react-router-dom";
import Login from "./components/Login";
import Messenger from "./components/Messenger";
import Register from "./components/Register";
import GenerateKeysTest from "./components/GenerateKeysTest";

function App() {
  return (
    <div>
      <BrowserRouter>
        <Routes>
          <Route path="/messenger/login" element={<Login/>}/>
          <Route path="/messenger/register" element={<Register/>}/>
          <Route path="/" element={<Messenger />} />
          <Route path="/messenger/generatekeys" element={<GenerateKeysTest />} />
        </Routes>
      </BrowserRouter>,
    </div>
  );
}

export default App;
