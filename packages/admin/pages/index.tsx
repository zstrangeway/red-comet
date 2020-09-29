import styles from "../styles/Home.module.css";
import Button from "@material-ui/core/Button";

const Home = (): JSX.Element => {
  return (
    <div className={styles.container}>
      <h1>Admin Confirm</h1>
      <Button>Hello World</Button>
    </div>
  );
};

export default Home;
